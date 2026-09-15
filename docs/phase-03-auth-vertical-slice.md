# Phase 3 — Auth Vertical Slice

## Objective

A second vertical slice through the same Clean Architecture shape
established in Phase 2 — entity → data source → repository → use cases →
Riverpod providers → screens — this time for Login/Register instead of
Books, proving the layering generalizes rather than being Books-specific.
`main.dart`'s `home:` now points at `LoginScreen` (`SplashScreen` stays
wired-but-commented, as before).

## What was built

### Domain — `lib/features/auth/domain/`

| File | Purpose |
|---|---|
| `entities/auth_session.dart` | `AuthSession` (`accessToken`, `expiresInMinutes`, `userId`, `role` (`UserRole.admin`/`.member`), `fullName`, `email`) — deliberately **not** the same type as a future Members-feature `Member` entity; Auth doesn't depend on Members, and a login response wouldn't return a full profile anyway |
| `repositories/auth_repository.dart` | Abstract `AuthRepository` — `login({email, password})` / `register({fullName, email, phoneNumber, password})`, both `Either<Failure, AuthSession>`. `register` takes **no `role` parameter** — see Decisions below |
| `usecases/login_user.dart`, `usecases/register_member.dart` | Thin wrappers around the repository, same intent as `GetBooks`/`GetBookById` — but see the divergence noted below |

### Data — `lib/features/auth/data/`

| File | Purpose |
|---|---|
| `models/auth_session_model.dart` | `AuthSessionModel` — `toEntity()` only (no API to parse `fromJson` from yet, since the mock datasource builds it directly) |
| `datasources/auth_local_datasource.dart` | Abstract `AuthLocalDataSource` + `AuthLocalDataSourceImpl`. In-memory seeded list of two accounts (`admin@library.com` / `admin123`, admin; `amaya@email.com` / `member123`, member); `login`/`register` each add a 500ms delay and throw `InvalidCredentialsException` / `EmailAlreadyExistsException` on failure. Registration always assigns `UserRole.member` |
| `repositories/auth_repository_impl.dart` | `AuthRepositoryImpl implements AuthRepository` — catches `InvalidCredentialsException`→`InvalidCredentialsFailure`, `EmailAlreadyExistsException`→`EmailAlreadyExistsFailure`, anything else→`UnexpectedFailure` |

### Functional core additions — `lib/core/error/`

- `failure.dart` gained `InvalidCredentialsFailure`, `EmailAlreadyExistsFailure`.
- `exceptions.dart` gained `InvalidCredentialsException`, `EmailAlreadyExistsException`.

Same shared `Failure`/`Exception` vocabulary Books already used — extended,
not duplicated per-feature.

### Presentation — `lib/features/auth/presentation/`

`providers/auth_providers.dart` (`@riverpod` codegen, same pattern as
`book_providers.dart`):

| Provider | Kind | Purpose |
|---|---|---|
| `authLocalDataSourceProvider`, `authRepositoryProvider`, `loginUserUseCaseProvider`, `registerMemberUseCaseProvider` | `@riverpod` functions | Standard composition-root wiring, same shape as the Books providers |
| `authControllerProvider` | `@riverpod class AuthController extends _$AuthController` | A **raw `Notifier<AsyncValue<AuthSession?>>`**, not an `AsyncNotifier<AuthSession?>` — see Decisions below. `build()` returns `const AsyncData(null)` (signed out) synchronously; `login()`/`register()` manually flip `state` to `AsyncLoading()` then `result.match((f) => AsyncError(f, ...), (s) => AsyncData(s))` |

`screens/login_screen.dart`, `screens/register_screen.dart` — both
`ConsumerStatefulWidget`s with local field-level validation (`_validate()`,
never touching Riverpod), watching `authControllerProvider` for
`isLoading`/`hasError`, and a `ref.listen` that `pushReplacement`s to
`BooksScreen` once `next.value` (the session) becomes non-null. Each has a
`_messageFor(Failure)` switch that shows the specific message for its
relevant failure type (`InvalidCredentialsFailure` on Login,
`EmailAlreadyExistsFailure` on Register) and a generic fallback otherwise.

### App wiring

`main.dart`'s `home:` now constructs `LoginScreen` (previously
`BooksScreen`); `SplashScreen`'s import is present but its `home:` line
stays commented out.

## Bugs found and fixed

- **`AsyncValue.valueOrNull` doesn't exist** on the resolved `riverpod`
  version (`3.4.2`) — that getter was Riverpod 2.x; in Riverpod 3, `.value`
  itself became the nullable getter (the old throwing `.value` was renamed
  `.requireValue`). Both `login_screen.dart` and `register_screen.dart`'s
  `ref.listen` callbacks were fixed from `next.valueOrNull` to `next.value`.

## Decisions made

- **`AuthController` is a raw `Notifier<AsyncValue<T>>`, not an
  `AsyncNotifier<T>`.** Deliberate: unlike `BookList`, there's nothing to
  auto-fetch at startup — no session persistence exists yet, so every cold
  start is signed-out. `build()` just sets `AsyncData(null)` synchronously,
  and the notifier only enters a loading/error/data cycle in response to an
  explicit `login()`/`register()` call. An `AsyncNotifier`'s
  `Future<T> build()` would force an unwanted auto-fetch on first watch.
- **`LoginUser`/`RegisterMember` don't extend the shared
  `UseCase<Result, Params>` base**, unlike `GetBooks`/`GetBookById`. Their
  multiple named parameters (`email`, `password`, ...) don't fit
  `UseCase.call(Params params)`'s single positional-argument shape. This is
  a genuine inconsistency, not a deliberate choice — see Open items.
- **Public registration never accepts a `role` parameter** —
  `AuthRepository.register()` has no `role` argument at all, so there is no
  code path that could let a caller register as Admin. The admin account
  exists only as a seeded mock user.
- **Password validation (min length, confirm-match) is presentation-layer
  only** — "do these two fields match" is never meaningful to send to a
  backend, so it isn't part of the domain/data contract.
- **The mock data source fabricates a token+claims bundle directly**,
  rather than a real JWT the client would decode. Documented as
  intentionally deferred (a `TODO(phase-18)` in the source) — faking a JWT
  now would be busywork with no payoff until there's a real one to decode.

## Open items for later phases

- `LoginUser`/`RegisterMember` don't conform to `UseCase<Result, Params>` —
  either give `UseCase` a params-object convention (e.g. a `LoginParams`
  class bundling the named args) so Auth can conform too, or stop treating
  `UseCaseBase` as universal and document it as Books-specific.
- No session persistence — every cold start begins signed out
  (`AsyncData(null)`); a real app needs to persist/restore the session
  (secure storage) instead of starting fresh every launch.
- No real token handling — `accessToken` is a fabricated string,
  `expiresInMinutes` is never checked or acted on (no auto-logout on
  expiry).
- No route guarding — nothing stops navigating straight to `BooksScreen`
  without going through Login/Register first; there's no router/guard
  layer yet.
- `SplashScreen` still isn't part of the actual navigation flow.
- No automated test coverage — see Testing below; also still true for
  Books.

## Testing

No automated tests exist for this feature yet — `test/widget_test.dart` is
still the default Flutter counter-app template (it references `MyApp`,
which doesn't even match this project's `LibraryApp`, so it wouldn't
compile as a real test today).

Manual smoke test, since `home:` already points at `LoginScreen`:

1. Login with a seeded account (`admin@library.com` / `admin123`, or
   `amaya@email.com` / `member123`) → should navigate to `BooksScreen`.
2. Login with a wrong password → should show the `InvalidCredentialsFailure`
   message inline, no navigation.
3. Register with a brand-new email → should succeed and navigate to
   `BooksScreen`.
4. Register with an already-used email (e.g. `admin@library.com`) → should
   show the `EmailAlreadyExistsFailure` message inline, no navigation.

## Next phase

Candidates: replace `test/widget_test.dart` with real unit tests for
`AuthController` (valid/invalid login, duplicate-email register) and
`BookList`; wire session persistence so Auth survives a cold start; or move
on to the Borrowings feature.
