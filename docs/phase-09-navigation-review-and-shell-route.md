# Phase 9 — Navigation Architecture Review & StatefulShellRoute Migration

## Objective

A deliberate architecture review of `core/navigation/app_router.dart` —
tracing every push/`go`/pop transition across the Auth Stack and Main
Stack, then fixing the issues that review actually found, rather than
adding a feature. The biggest one: every bottom-nav tab switch used
`context.go(...)`, which replaces the current location and tears the
tab down — typing into Books' search field, switching to Borrowings, and
switching back lost the query text and scroll position every time.

## What was built

### `StatefulShellRoute.indexedStack` for the bottom nav

`app_router.dart`'s single flat `/home` `GoRoute` became a
`StatefulShellRoute.indexedStack` with one `StatefulShellBranch` per
tab, in the same order as the nav bar's items (Borrowings=0, Books=1,
Profile=2) so `navigationShell.currentIndex` lines up with
`AppBottomNavBar`'s `currentIndex` with no per-screen bookkeeping:

- Branch 0 — `/home/borrowings` (`MyBorrowingsScreen`) + child `:id` (`BorrowingDetailsScreen`)
- Branch 1 — `/home` (`BooksScreen`) + children `book/:id`, `search`, `notifications`
- Branch 2 — `/home/profile` (`ProfileScreen`)

Each branch keeps its own `Navigator` alive inside the `IndexedStack`
the shell wraps, so switching tabs now preserves scroll position and
in-progress state instead of rebuilding from scratch.

`core/navigation/home_shell.dart` (new) — `HomeShell`, the single place
`AppBottomNavBar` is now constructed:

```dart
Scaffold(
  body: navigationShell,
  bottomNavigationBar: AppBottomNavBar(
    items: const [...],
    currentIndex: navigationShell.currentIndex,
    onTap: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
  ),
)
```

`AppBottomNavBar`'s construction, hardcoded `items` list, and `onTap`
switch were removed from `books_screen.dart`, `my_borrowings_screen.dart`,
and `profile_screen.dart` — each now returns only its body content, no
`Scaffold`-level bottom nav of its own.

### Navigation rule, documented

A comment block on `router()` in `app_router.dart` now states the
convention explicitly:

- Tab switches → `navigationShell.goBranch(i)` (only `HomeShell` does this) — never `context.go('/home/...')`.
- Drilling into more content (a book, a borrowing, search results, notifications) → `context.push(...)`, so back returns you to where you were.
- Deliberately resetting a tab to its root from an error/empty state (e.g. "Browse Books" after an empty Borrowings list, or `NotFoundRouteScreen`'s buttons) → `context.go('/home')` is correct here, not a bug — the intent is "start fresh at Books' root," not "preserve wherever Books was last left."

Verified after the migration: no stray tab-switch `context.go` calls
remain anywhere in `lib/features/` — every remaining `context.go` is
either a deliberate root-reset CTA or the one documented Auth Stack
exception below.

### Splash timing dead code removed

`SplashScreen` (`features/auth/presentation/screens/splash_screen.dart`)
had `holdDuration`/`onFinished` constructor params and a
`Future.delayed(widget.holdDuration, widget.onFinished!)` call in
`initState()`, from an earlier design where the splash screen drove its
own navigation. The one route that builds it
(`GoRoute(path: '/splash', builder: (_, _) => const SplashScreen())`)
never passed either param, so the mechanism was always inert — the real
2.4s hold and destination logic lives entirely in
`appBootstrapProvider`. Removed both params and the timer; replaced the
misleading "wire `onFinished` to your router" header comment with one
pointing at `appBootstrapProvider` as the actual source of truth.

### Register screen — discard confirmation

`register_screen.dart` gained `_hasChanges` (any field non-empty) and
`_confirmDiscardAndPop()` (shows `AppConfirmSheet` only when dirty,
pops otherwise). Wired to both:

- The "Already have an account? Login" tap (previously a bare `context.pop()`).
- A `PopScope(canPop: !_hasChanges, onPopInvokedWithResult: ...)` wrapper around the whole screen, so the OS back button/gesture is guarded too, not just the on-screen link.

This brings Register in line with the confirm-before-losing-work
convention `AppConfirmSheet` already established elsewhere (borrow/return)
— it was the one screen skipping it.

### Onboarding ↔ router cross-reference

`OnboardingScreen._finish()`'s `context.go('/login')` is the one
deliberate exception to `redirect` owning every stack transition. Each
side now names the other directly: `_finish()`'s comment points at
`app_router.dart`'s "Navigation rule" comment, and the router's guard
comment names `OnboardingScreen._finish()` instead of a vague
"onboarding's own explicit call."

## Bugs found and fixed

Two rounds of self-implementation attempts (by the user, before this
phase's fixes landed) introduced real compile errors, since reverted
along with the attempts that caused them — noted here since they're
instructive go_router API traps, not because the broken code shipped:

- `state.params['id']` / `state.queryParams['q']` — not valid on the installed `go_router: ^18.0.1`. The correct API is `state.pathParameters['id']` and `state.uri.queryParameters['q']` (verified directly against the installed package source, `go_router-18.0.1/lib/src/state.dart`).
- `PopScope`'s `onPopInvokedWithDidPop` — renamed to `onPopInvokedWithResult` in the installed Flutter SDK (`3.47.2`); `onPopInvokedWithDidPop` never existed under that name in this version (verified against `flutter/packages/flutter/lib/src/widgets/pop_scope.dart`).
- `BookSearchResultsScreen(query: query)` — the constructor's actual parameter is `initialQuery`, not `query`.
- A `notifications` route builder with an empty body (just a comment, no return statement) — fixed to `builder: (_, _) => const NotificationsScreen()`.

## Decisions made

- **Deep-link / App Links registration (Android manifest `intent-filter`, iOS `CFBundleURLTypes`) was attempted and then reverted.** A `booksnu://` custom-scheme intent filter was added to `AndroidManifest.xml` and `Info.plist`, verified against the actual `applicationId` (`com.example.library_1`), but the user reverted both files before testing. Not currently present — see Open items.
- **Kept a single root `Navigator` via `StatefulShellRoute`, not a fully custom nested-navigator setup.** `StatefulShellRoute.indexedStack` is go_router's standard, built-in answer to "preserve per-tab state under a shared bottom nav" — no need for a hand-rolled solution.
- **Branch order (Borrowings/Books/Profile) matches the pre-existing nav bar item order** rather than reordering to something more "logical" (e.g. Books first) — preserves the exact UX users already had; `navigationShell.currentIndex` needing to line up with `AppNavItem` order was the actual constraint, not a preference.

## Open items for later phases

- **Deep linking is still not wired up.** No Android `intent-filter` / iOS `CFBundleURLTypes` currently exists, so none of go_router's path-based routes (`/home/book/:id`, etc.) are reachable from outside the app (a push notification, a shared link). The manifest/plist changes to fix this are documented in-session but were reverted before landing — redo `android/app/src/main/AndroidManifest.xml` (`<intent-filter>` with `android:scheme="booksnu"` on `.MainActivity`) and `ios/Runner/Info.plist` (`CFBundleURLTypes` with the same scheme) if this becomes a priority.
- No automated widget/integration tests cover the `StatefulShellRoute` migration (tab-switch state preservation, `HomeShell`'s `goBranch` wiring).
- `RegisterScreen`'s discard-confirmation is the one screen with this treatment — audit whether any other screen with meaningful in-progress state (none identified in this phase) should get the same `PopScope`/`AppConfirmSheet` pattern.

## Testing

No automated tests added. Manual verification:

1. `flutter analyze` clean across the whole project after every step of the migration (router restructure, per-screen nav-bar removal, splash cleanup, register `PopScope`).
2. Type into Books' search field, switch to Borrowings via the bottom nav, switch back to Books → search text and scroll position preserved (the concrete regression test for the `StatefulShellRoute` migration).
3. `grep`-verified no stray `context.go` tab-switch calls remain in `lib/features/` after the migration.
4. Register screen: type into any field, tap the OS back gesture or the "Login" link → `AppConfirmSheet` shown; confirm discards and pops, cancel stays on the form; with all fields empty, both paths pop immediately with no prompt.

## Next phase

Candidates: redo the deep-link manifest/plist registration if it becomes
a priority; automated tests for the shell-route migration; or continue
the Borrowings/Members phase documentation backfill noted in Phase 8's
numbering note.
