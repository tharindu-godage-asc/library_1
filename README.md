# BooksnU

*Read more. Discover more.*

A Flutter library-management app, built feature-by-feature as a series of
documented phases (see [`docs/`](docs/)). Currently implements a full
vertical slice of the **Books** feature; other features are scaffolded but
not yet built.

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
| Borrowings | Scaffolded only (empty folders) — bottom-nav tab is a placeholder |
| Auth | Scaffolded only |
| Members / Profile | Scaffolded only |
| Splash | Screen exists, not yet wired into app startup |

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
  core/            design tokens, reusable widgets, error types, UseCase base
  features/
    books/         domain / data / presentation — fully implemented
    borrowings/    scaffolded
    auth/          scaffolded
    members/       scaffolded
    splash/        splash_screen.dart only
  main.dart
docs/              one dated write-up per phase: objective, what was built,
                   bugs found, decisions made, open items, next phase
```

## Docs

- [`docs/phase-01-theme-and-core-widgets.md`](docs/phase-01-theme-and-core-widgets.md) — design tokens, reusable widgets
- [`docs/phase-02-books-vertical-slice.md`](docs/phase-02-books-vertical-slice.md) — Books feature end-to-end, Riverpod conversion, search

## TODO

- **Value object implementation** — domain entities currently pass raw
  `String`/`int` for things with real invariants (`isbn`, `id`,
  `publishedYear`). Wrap these in dedicated value objects (e.g. `Isbn`,
  `BookId`) that validate on construction, instead of trusting every caller
  to pass a well-formed primitive.
- Borrowings feature — real data behind the reminder banner and the
  Borrowings bottom-nav tab (currently hardcoded mock due-dates).
- Auth feature.
- Members / Profile feature.
- Wire `SplashScreen` into actual app startup (`main.dart`'s `home:` still
  points at `BooksScreen` directly).
- Per-book cover images — no cover field exists yet in `Book`/`BookModel`/
  `books.json`; cards currently show a generic icon placeholder.
- Remove `assets/images/book cover.jpg` (and its `pubspec.yaml` entry) —
  unused since the icon-placeholder fix.
- Consider `equatable` for `Failure` once tests start asserting on
  `Either`/`Failure` values directly (not needed yet — see `docs/` decision
  log).
