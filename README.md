# BooksnU

*Read more. Discover more.*

A Flutter library-management app, built feature-by-feature as a series of
documented phases (see [`docs/`](docs/)). Implements full vertical
slices of **Books**, **Auth** (including onboarding and cold-start
session persistence), **Borrowings**, **Members/Profile**, and
**Notifications**, plus a global illustrated error/empty-state system
and a `StatefulShellRoute`-based bottom nav

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
| Books | Implemented — list, search, details, sorted "Newest Picks" / "Recommended" rails, bundled-JSON data source |
| Auth | Implemented — Login/Register against an in-memory seeded mock data source, session persisted via secure storage across cold starts (see caveat below) |
| Onboarding | Implemented — shown once, gated behind a `shared_preferences` flag |
| Borrowings | Implemented — borrow/return flow, business-rule validation (availability, borrow limit, member-active check), overdue status computed at fetch time. Bottom-nav tab, own `StatefulShellRoute` branch (see Phase 9) |
| Members / Profile | Implemented — profile view/edit, logout. Own `StatefulShellRoute` branch |
| Notifications | Implemented — derived from Borrowings + Books data (due-soon/overdue/returned), no dedicated data/domain layer of its own |
| Splash | Wired into app startup — drives the cold-start onboarding/login/home decision |
| Global error & empty states | Implemented — illustrated No-Internet/500/404 screens and empty-state screens, connectivity-aware (see Phase 8) |
| Navigation | go_router with a single `redirect` guard (Auth Stack ↔ Main Stack) and a `StatefulShellRoute` for the 3 bottom-nav tabs (see Phase 9) |

## Getting started

```bash
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
                   secure session storage, onboarding preference, app bootstrap,
                   connectivity, go_router + StatefulShellRoute nav shell
  features/
    books/         domain / data / presentation — fully implemented
    auth/          domain / data / presentation — fully implemented, session
                   persisted via secure storage; splash_screen.dart lives here,
                   wired into app startup via appBootstrapProvider
    borrowings/    domain / data / presentation — fully implemented
    members/       domain / data / presentation — fully implemented (Profile)
    notifications/ presentation only — derived from Borrowings + Books data
  main.dart
docs/              one dated write-up per phase: objective, what was built,
                   bugs found, decisions made, open items, next phase
```

## TODO

- **Backend implementation** — every feature (Books, Auth, Borrowings,
  Members, Notifications) currently runs on mock in-memory or bundled-JSON
  data sources. Stand up a real backend REST API with
  Postgres database and swap it in behind the existing repository
  interfaces in each feature's `data/` layer — `domain`/`presentation`
  shouldn't need to change. Needed alongside this:
  - Real auth server issuing the access/refresh tokens `AuthController`
    already expects, instead of the mock token issuer.
  - Persistent storage for borrow/return state, member profiles, and book
    inventory (replacing `books.json`).



- **See all Screen Implementation** — Implement See more screens for Newest Picks and Recommended for You sections