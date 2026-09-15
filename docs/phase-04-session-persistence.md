# Phase 4 — Session Persistence, Onboarding Gate, Splash Wiring

## Objective

Close the two biggest TODOs left after Phase 3: every cold start began
signed-out (no session persistence), and `SplashScreen` existed but wasn't
part of the actual navigation flow. This phase wires both, plus gates
onboarding behind a device preference so it's only shown once.

## What was built

### Core additions — `lib/core/`

| File | Purpose |
|---|---|
| `storage/secure_session_storage.dart` | `SecureSessionStorage` — wraps `flutter_secure_storage` behind an interface-shaped class, same reasoning as `BookLocalDataSource` sitting behind an interface. `save()`/`read()`/`clear()` persist an `AuthSession`'s fields as individual key/value pairs; `read()` treats a partially-written record (e.g. some keys missing) as corrupted and clears it rather than crashing |
| `preferences/onboarding_preference.dart` | `OnboardingPreference` — wraps `shared_preferences` for a single bool flag (`has_completed_onboarding`). Deliberately **not** run through `Either<Failure, T>`: it's a device preference, not a business operation, so a read failure just defaults to "show onboarding" |
| `bootstrap/app_bootstrap_provider.dart` | `appBootstrapProvider` (`@riverpod` `Future<BootstrapDestination>`) — the single decision point for what the app shows at cold start: `onboarding`, `login`, or `home`. Preserves the splash screen's original 2.4s brand-timing hold (`Future.delayed`), now run concurrently with the real onboarding/session checks instead of being a bare timer |

### Domain — `lib/features/auth/domain/`

| File | Purpose |
|---|---|
| `usecases/restore_session.dart` | `RestoreSession` — thin wrapper around `AuthRepository.restoreSession()` |
| `usecases/logout_user.dart` | `LogoutUser` — thin wrapper around `AuthRepository.logout()` |
| `repositories/auth_repository.dart` | Gained `restoreSession()` (`Either<Failure, AuthSession?>`) and `logout()` (`Either<Failure, Unit>`) |

### Data — `lib/features/auth/data/`

`repositories/auth_repository_impl.dart` — now takes a `SecureSessionStorage`
alongside the existing `AuthLocalDataSource`:

- `login()` saves the resulting session to secure storage before returning it.
- `restoreSession()` reads from secure storage, wrapping any thrown error as `UnexpectedFailure`.
- `logout()` clears secure storage.

### Presentation — `lib/features/auth/presentation/`

`providers/auth_providers.dart`:

| Provider | Change |
|---|---|
| `secureSessionStorageProvider`, `onboardingPreferenceProvider` | New — composition-root wiring for the two new core classes |
| `authRepositoryProvider` | Now injects `secureSessionStorageProvider` alongside the local data source |
| `restoreSessionUseCaseProvider`, `logoutUserUseCaseProvider` | New — same pattern as the existing use-case providers |
| `AuthController.build()` | No longer synchronously returns `AsyncData(null)`. Now calls `RestoreSession` and matches the result — `AsyncData(session)` if one was persisted, `AsyncData(null)` otherwise. `AuthController` is `@Riverpod(keepAlive: true)` so this restore only ever runs once per app process |
| `AuthController.logout()` | New — calls `LogoutUser` (best-effort; state is forced to `AsyncData(null)` regardless of the use case's result) |

`screens/onboarding_screen.dart` — `_finish()` now calls
`onboardingPreferenceProvider.markCompleted()` before navigating to
`LoginScreen`. This is load-bearing: skip it and `appBootstrapProvider`
sends the user right back to onboarding on the next cold start.

`screens/books_screen.dart` — gained a temporary "Log out (temporary)"
text button at the bottom of the screen that calls
`authControllerProvider.notifier.logout()` and navigates back to
`LoginScreen`. Marked `TODO(members)` for removal once a real Profile
screen exists.

### App wiring — `lib/main.dart`

`LibraryApp.build()` now watches `appBootstrapProvider` and switches on it:
`loading` → `SplashScreen`, `error` → `LoginScreen` (fail safe — never
strand the user on a broken splash), `data` → `OnboardingScreen` /
`LoginScreen` / `BooksScreen` per `BootstrapDestination`. This replaces the
previous hardcoded `home: LoginScreen()`.

## Bugs found and fixed

- None new — `AsyncValue.valueOrNull` fix from Phase 3 stands.

## Decisions made

- **`AuthController.build()` uses `ref.read(authControllerProvider.future)`
  from within `appBootstrapProvider`, not `ref.watch`.** The bootstrap
  decision must run exactly once, at true cold start. Watching would
  re-trigger the whole function — including the 2.4s minimum-hold delay —
  on every later login/logout, flashing the splash screen back up
  mid-session. Runtime sign-in/out transitions are handled by explicit
  navigation at the screen level instead (`LoginScreen`'s `ref.listen`, the
  logout button on `BooksScreen`). The bootstrap provider only owns the
  cold-start decision.
- **`OnboardingPreference` skips the `Either<Failure, T>` convention** used
  everywhere else in Auth. A device-preference read/write isn't a business
  operation with meaningful failure modes to surface to the user — "default
  to showing onboarding" is already the correct behavior on any read error.
- **`flutter_secure_storage` pinned to `^10.3.1`**, down from the `^11.0.0`
  already in `pubspec.yaml` — the newer major didn't resolve cleanly
  against this project's other dependencies.

## Open items for later phases

- **`register()` doesn't persist a session.** `AuthRepositoryImpl.login()`
  calls `_sessionStorage.save(session)`; `register()` does not, so a freshly
  registered account is signed in for the current app run (`AuthController`
  state is set from the use-case result either way) but won't survive a
  cold start — the user would land back on `LoginScreen` next launch even
  though registration "succeeded." Worth confirming whether this is
  intentional (e.g. force explicit login post-registration) or a gap.
- No real token handling — `accessToken` is still a fabricated string;
  `expiresInMinutes` is never checked or acted on (no auto-logout on
  expiry, no refresh).
- No route guarding — nothing stops navigating straight to `BooksScreen`
  without going through the bootstrap flow; there's still no router/guard
  layer.
- The "Log out (temporary)" button on `BooksScreen` needs to move to a real
  Profile screen once Members/Profile is built.
- `LoginUser`/`RegisterMember` still don't conform to
  `UseCase<Result, Params>` (carried over from Phase 3).
- No automated test coverage for `AuthController`'s restore/logout paths,
  `SecureSessionStorage`, or `OnboardingPreference`. `test/widget_test.dart`
  was updated to smoke-test that the app shows `SplashScreen` on cold
  start, but that's the only coverage that exists.

## Testing

No automated tests beyond the updated smoke test (`test/widget_test.dart`
now pumps `LibraryApp` and asserts `SplashScreen` renders, flushing the
2.4s minimum-hold timer so no pending timer leaks into teardown).

Manual smoke test:

1. Fresh install / cleared storage → cold start shows `SplashScreen`, then
   `OnboardingScreen`.
2. Finish onboarding → lands on `LoginScreen`; relaunch the app → should
   skip straight past onboarding to `LoginScreen` (not `OnboardingScreen`
   again).
3. Log in with a seeded account → lands on `BooksScreen`; relaunch the app
   → should skip straight to `BooksScreen` (session restored), not
   `LoginScreen`.
4. Tap "Log out (temporary)" on `BooksScreen` → returns to `LoginScreen`;
   relaunch → should land back on `LoginScreen`, not `BooksScreen`.
5. Register a new account → lands on `BooksScreen` for that session; per
   the open item above, relaunching currently returns to `LoginScreen`
   rather than staying signed in — confirm whether that's expected.

## Next phase

Candidates: decide and fix the register-session-persistence gap above;
route guarding; real automated tests for `AuthController`/session storage;
or move on to the Borrowings feature.
