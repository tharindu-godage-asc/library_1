# BooksnU

*Read more. Discover more.*

A Flutter library-management app, built feature-by-feature as a series of
documented phases (see [`docs/`](docs/)). Implements full vertical
slices of **Books**, **Auth** (Keycloak SSO, onboarding and cold-start
session persistence), **Borrowings**, **Members/Profile**, and
**Notifications**, plus a global illustrated error/empty-state system
and a `StatefulShellRoute`-based bottom nav. Books, Borrowings and Members
talk to a real backend (**Library.Api**), authenticated via **Keycloak**.

## Architecture

Clean Architecture, per feature, under `lib/features/<feature>/`:

```text
domain/          entities, abstract repositories, use cases — pure Dart, no Flutter/IO
data/            models (JSON <-> entity), data sources, repository implementations
presentation/    screens, widgets, Riverpod providers
```

The dependency rule flows inward: `presentation` → `domain` ← `data`.
`domain` never imports from `data` or `presentation`; `data` implements the
contracts `domain` declares. Shared, feature-agnostic code (error types,
the `UseCase` base class, design tokens, reusable widgets) lives in
`lib/core/`.

- **State/DI** — [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod)
  with [`riverpod_generator`](https://pub.dev/packages/riverpod_generator)
  (`@riverpod` codegen). Each feature's `presentation/providers/` file is
  its composition root — the only place that wires a concrete repository
  implementation into an abstract one.
- **Error handling** — [`fpdart`](https://pub.dev/packages/fpdart)'s
  `Either<Failure, T>`. Data sources throw; repositories catch and convert
  to a `Failure`; providers `.match()` the `Either` once so the UI only ever
  sees a plain `AsyncValue`.

## Features

| Feature | Status |
|---|---|
| Books | Implemented — list, search, details, sorted "Newest Picks" / "Recommended" rails, fetched from Library.Api (`GET /api/books`, all pages) (Phase 14) |
| Auth | Implemented — Login/Register via Keycloak SSO (OAuth2/OIDC through `flutter_appauth`), session persisted via secure storage across cold starts (Phase 13) |
| Onboarding | Implemented — shown once, gated behind a `shared_preferences` flag |
| Borrowings | Implemented — borrow/return against Library.Api, overdue status computed client-side. Bottom-nav tab, own `StatefulShellRoute` branch (Phases 9, 15) |
| Members / Profile | Implemented — profile view/edit, logout, backed by Library.Api (`/api/members/me`). Own `StatefulShellRoute` branch |
| Notifications | Implemented — derived from Borrowings + Books data (due-soon/overdue/returned), no dedicated data/domain layer of its own |
| Splash | Wired into app startup — drives the cold-start onboarding/login/home decision |
| Global error & empty states | Implemented — illustrated No-Internet/500/404 screens and empty-state screens, connectivity-aware (see Phase 8) |
| Navigation | go_router with a single `redirect` guard (Auth Stack ↔ Main Stack) and a `StatefulShellRoute` for the 3 bottom-nav tabs (see Phase 9) |

## Configuration

Copy `.env.example` to `.env` (loaded by `flutter_dotenv`) and adjust:

| Key | Purpose |
|---|---|
| `KEYCLOAK_ISSUER` | Keycloak realm URL, e.g. `http://10.0.2.2:8081/realms/library` |
| `KEYCLOAK_CLIENT_ID` | OAuth client id (`library-flutter`) |
| `KEYCLOAK_REDIRECT_URL` | App redirect scheme (`com.example.library1:/oauthredirect`) |
| `API_BASE_URL` | Library.Api base URL, e.g. `http://10.0.2.2:5281/api` |

`10.0.2.2` is the Android emulator's alias for the host machine; use your
host's LAN IP on a physical device.

## Getting started

Prerequisites: a running Keycloak (realm `library`) and Library.Api.

```bash
cp .env.example .env                                        # then edit values
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.g.dart for @riverpod providers
flutter run
```

Re-run `build_runner` (or `dart run build_runner watch`) whenever a
`@riverpod`-annotated provider changes.

## Project structure

```text
lib/
  core/            design tokens, reusable widgets, error types, UseCase base,
                   env/API/Keycloak config, HTTP API client, secure session
                   storage, onboarding preference, app bootstrap,
                   connectivity, go_router + StatefulShellRoute nav shell
  features/
    books/         domain / data / presentation — remote (Library.Api) datasource
    auth/          domain / data / presentation — Keycloak datasource, session
                   persisted via secure storage; splash_screen.dart lives here,
                   wired into app startup via appBootstrapProvider
    borrowings/    domain / data / presentation — remote (Library.Api) datasource
    members/       domain / data / presentation — remote (Library.Api) datasource
    notifications/ presentation only — derived from Borrowings + Books data
  main.dart
_specs/            feature specs written before each integration
docs/              one dated write-up per phase: objective, what was built,
                   bugs found, decisions made, open items, next phase
```

## Notes

The original mock/bundled-JSON datasources (`*_local_datasource.dart`,
`assets/data/`) remain in the repo and still define each datasource
contract, but the providers no longer instantiate them. Known gap: book
copy-count changes from borrow/return aren't persisted server-side, as
Library.Api has no book-update endpoint (see Phase 14).

## TODO

- **Notifications backend** — still derived client-side from Borrowings +
  Books data; consider server-driven notifications.
- **See all Screen Implementation** — Implement See more screens for Newest Picks and Recommended for You sections
