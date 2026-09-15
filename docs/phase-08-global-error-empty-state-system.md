# Phase 8 — Global Error & Empty-State System

> **Note on numbering.** The go_router migration referenced throughout
> `docs/diagrams.md` as "Phase 5" was never given its own `phase-05-*.md`
> write-up, and the Borrowings and Members features were built and
> merged after it with no phase docs at all. Those gaps predate this
> phase and aren't backfilled here — this doc only covers work actually
> done in this phase, numbered to continue the sequence without
> claiming history it doesn't have.

## Objective

Every failed or empty data state in the app rendered as plain, generic
text (`ErrorView`/`EmptyView` in `core/widgets/app_state_views.dart`) —
no illustrations, no distinction between "not found" vs "server error"
vs "offline," and a hardcoded message duplicated per screen. Design
produced illustrated mockups for three global error states (No Internet,
Something Went Wrong/500, We Couldn't Find That/404) and three
empty-state screens (Books search, Borrowings, Notifications), with the
illustration assets already sitting unused in `assets/illustrations/`.
This phase wires all of it in, on Riverpod (the project's existing state
management), not BLoC — see Decisions below for why that changed
mid-phase.

## What was built

### Core additions — `lib/core/`

| File | Purpose |
|---|---|
| `connectivity/connectivity_provider.dart` | `enum AppConnectivityStatus { online, offline }` + `@Riverpod(keepAlive: true) Stream<AppConnectivityStatus> connectivityStatus(Ref ref)` — wraps `connectivity_plus`, seeds from `checkConnectivity()` then follows `onConnectivityChanged`. `keepAlive` so the subscription is shared app-wide; any screen reads it via `ref.watch(connectivityStatusProvider)` |
| `error/app_error_type.dart` | `sealed class AppErrorType` (`NotFoundErrorType`, `ServerErrorType`, `UnexpectedErrorType`, `AccessDeniedErrorType`, `BusinessRuleErrorType(String message)`) + `appErrorTypeFrom(Failure)` — an **exhaustive** switch over all 9 `Failure` subtypes, no wildcard arm (see Bugs found and fixed) |
| `error/widgets/error_state_view.dart` | `ErrorStateView` — the drop-in replacement for `ErrorView` everywhere. A `ConsumerWidget`: if `connectivityStatusProvider` reports offline, always shows the No-Internet illustration regardless of the actual failure; otherwise switches on `appErrorTypeFrom()` to pick 404/500/Access-Restricted/Action-Not-Available |
| `error/widgets/not_found_route_screen.dart` | `NotFoundRouteScreen` — wired into `GoRouter`'s `errorBuilder`, for unmatched routes. Unlike `ErrorStateView`, this has no parent tab shell to sit inside, so it builds its own full `AppGradientScaffold` |
| `widgets/illustrated_state_view.dart` | `IllustratedStateView` — one generic widget (illustration + heading + message + optional primary button + optional secondary text link), reused by every error screen *and* every empty-state screen. Built from existing `AppButton`/`AppTextStyles`/`AppSpacing`/`AppColors` |
| `widgets/app_state_views.dart` | `ErrorView` and `EmptyView` deleted (`LoadingView` kept) — fully superseded by `ErrorStateView`/`IllustratedStateView` |

### Dependency & asset registration — `pubspec.yaml`

- Added `connectivity_plus: ^6.1.5` — the only new package dependency (no `flutter_bloc`/`equatable`).
- Registered the 6 previously-unused illustrations under `flutter: assets:`: `illustration-no-connection.png`, `illustration-server-error.png`, `illustration-not-found.png`, `illustration-no-results.png`, `illustration-no-borrowings.png`, `illustration-no-notifications.png`.

### Provider fix — read-only providers now preserve `Failure` type

`book_providers.dart` (`BookList.build()`, `bookById`), `borrowing_providers.dart` (`myBorrowings`, `borrowingById`), `member_providers.dart` (`myProfile`) all changed their `.match()` failure arm from `(failure) => throw Exception(failure.message)` to `(failure) => throw failure`. See Bugs found and fixed.

### Screen migrations

| Screen | Change |
|---|---|
| `books_screen.dart` | `ErrorView` → `ErrorStateView` (error branch only; the inline "no books match your search" text in the scrolling home feed stays plain text — not a full illustrated screen) |
| `book_details_screen.dart`, `borrow_confirm_screen.dart`, `borrowing_details_screen.dart`, `profile_screen.dart` | `ErrorView` → `ErrorStateView` |
| `book_search_results_screen.dart` | `ErrorView` → `ErrorStateView`; empty results → `IllustratedStateView` ("No Books Found", `illustration-no-results.png`, dynamic message including the actual query, "Clear Search" action) |
| `my_borrowings_screen.dart` | `ErrorView` → `ErrorStateView`; empty list → `IllustratedStateView` ("No Borrowings Yet", `illustration-no-borrowings.png`, "Browse Books" → `context.go('/home')`); the nested "book failed to load" soft-degrade case (previously `EmptyView`) became a plain `Center(Text(...))` — deliberately *not* upgraded to a full illustrated screen, since it's a secondary lookup failure inside an otherwise-successful list, not the screen's primary state |
| `borrowing_details_screen.dart` | Same soft-degrade treatment for its nested book-lookup failure |
| `notifications_screen.dart` | `ErrorView` → `ErrorStateView`; empty → `IllustratedStateView` ("You're All Caught Up", `illustration-no-notifications.png`, no action button) |

### Dead code removed

`lib/features/borrowings/presentation/screens/borrow_confirm_screen.dart` (`BorrowConfirmScreen`) — a fully-built alternate "Confirm Borrowing" screen, never registered in `app_router.dart`'s routes and never imported anywhere. The live borrow-confirmation UX has always been `AppConfirmSheet` shown directly from `BookDetailsScreen`.

## Bugs found and fixed

- **Read-only providers discarded the `Failure` subtype.** `result.match((failure) => throw Exception(failure.message), ...)` threw a generic `Exception`, so by the time it reached `AsyncError.error`, `NotFoundFailure` and `ServerFailure` were indistinguishable — `ErrorStateView` couldn't have picked the right illustration. Fixed by rethrowing the `Failure` object itself (`throw failure`), matching what the mutation controllers (`BorrowActionController`, etc.) already did via `AsyncError(failure, ...)`.
- **`appErrorTypeFrom`'s wildcard arm was a landmine.** An initial version used `_ => AppErrorType.unexpected` for anything that wasn't `NotFoundFailure`/`ServerFailure`. Since `Failure` is `sealed` with exactly 9 subtypes, this defeated the compiler's exhaustiveness checking — a new `Failure` subtype, or reusing one of the 6 currently-mutation-only failures (`MemberInactiveFailure`, `BookUnavailableFailure`, `BorrowingLimitExceededFailure`, `InvalidCredentialsFailure`, `EmailAlreadyExistsFailure`, `AlreadyReturnedFailure`) inside a page-level query provider, would silently render as a generic "Something Went Wrong" 500 instead of something intentional. Fixed by converting `AppErrorType` from a plain `enum` to a `sealed class` hierarchy and writing an exhaustive switch with no wildcard — the compiler now refuses to build if a 10th `Failure` subtype is ever added without an explicit mapping.

## Decisions made

- **Riverpod, not BLoC.** The user's original ask was to build this "with BLoC." The app is 100% Riverpod today (no `flutter_bloc`/`equatable` dependency exists anywhere) — after discussing the tradeoff, the call was to keep everything on Riverpod, consistent with every other feature. `connectivityStatusProvider` (a `StreamProvider`) fills the role a `ConnectivityBloc` would have.
- **Error screens stay inline per-screen, not a global overlay.** Considered a true app-wide error boundary (a single bloc/provider any part of the app could dispatch a failure to, taking over the full screen). Rejected: the mockups themselves keep the bottom nav visible, matching how the app already renders errors today (inline content inside each screen's existing `Scaffold`, driven by that screen's own Riverpod `AsyncValue.error`) — no architectural reason to change that shape.
- **`AccessDeniedErrorType`/`BusinessRuleErrorType` reuse the server-error illustration.** No bespoke illustration exists for "access denied" or "business rule rejection," and neither is reachable via any page-level provider today (both only ever occur as mutation/action failures, surfaced inline via each screen's own `_messageFor(Failure)` pattern, never through `ErrorStateView`). Reusing the existing illustration with a distinct heading was preferred over inventing new art for branches nothing currently exercises.
- **Navigation-level 404 (`NotFoundRouteScreen`, unmatched route) and domain-level 404 (`NotFoundFailure` → `ErrorStateView`) stay fully decoupled**, sharing only the same illustration/heading for visual consistency. One is go_router's `errorBuilder` firing before the app ever reaches domain/data; the other is a repository returning `NotFoundFailure` for a valid route with a missing entity. No code ties them together, and none should.

## Open items for later phases

- `AccessDeniedErrorType`/`BusinessRuleErrorType` are currently dead branches in practice — nothing in the app reaches them through `ErrorStateView` today. If a future feature reuses one of those `Failure` subtypes inside a page-level query provider, revisit whether the reused server-error illustration is still the right call, or whether it deserves its own art.
- No automated tests exist for `appErrorTypeFrom`'s exhaustiveness or `ErrorStateView`'s offline-override behavior.
- `connectivity_plus` is exercised manually (toggling airplane mode) — no test coverage for the `Stream<AppConnectivityStatus>` mapping logic itself.

## Testing

No automated tests added. Manual smoke test:

1. Toggle the device/emulator into airplane mode → any screen with a failing/loading provider shows the No-Internet illustration regardless of the underlying failure type; restore connectivity and hit "Try Again" → normal content loads.
2. Search for a nonsense query (e.g. "zzzzzzz") on the Books search results screen → "No Books Found" illustration, dynamic message quoting the query, "Clear Search" button — verified live on an Android emulator.
3. Navigate to a nonexistent route → `NotFoundRouteScreen`, not go_router's default error page.
4. Empty Borrowings (member with no borrowings) and empty Notifications show their respective illustrations and headings.
5. `flutter analyze` clean throughout (only a pre-existing, unrelated `withOpacity` deprecation info, later fixed independently).

## Next phase

Candidates: automated coverage for `appErrorTypeFrom`/`ErrorStateView`; revisit `AccessDeniedErrorType`/`BusinessRuleErrorType` illustrations if either ever becomes reachable; or move to the navigation architecture work in Phase 9.
