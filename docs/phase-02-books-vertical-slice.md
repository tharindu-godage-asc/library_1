# Phase 2 — Books Vertical Slice

## Objective

Build the first real feature end-to-end — entity → data source → repository
→ use cases → screens — replacing the Phase 1 component gallery as
`main.dart`'s `home:`.

Originally shipped with manual DI and a plain `StatefulWidget`/`setState`
load-state enum (no Riverpod). That conversion — originally slated as "Phase
3" — has since landed in place on this same slice: DI now runs through
`riverpod_generator`, and the previously-unwired search field is now
functional. This doc describes the vertical slice as it stands now, not the
Phase 1 snapshot.

## What was built

### Domain — `lib/features/books/domain/`

| File | Purpose |
|---|---|
| `entities/book.dart` | `Book` — plain domain entity (`id`, `title`, `author`, `isbn`, `publishedYear`, `totalCopies`, `availableCopies`, `description`), `isAvailable` getter, `copyWith`, `Book.empty()` fallback |
| `repositories/book_repository.dart` | Abstract `BookRepository` contract — `getBooks()` / `getBookById(id)`, both returning `Either<Failure, T>` |
| `usecases/get_books.dart`, `usecases/get_book_by_id.dart` | Thin `UseCase` wrappers around the repository — the only thing a presentation-layer provider is allowed to call directly |

The repository *implementation* is deliberately **not** here — see Data below.
An earlier version of this slice had `BookRepositoryImpl` living under
`domain/repositories/`, which is backwards for Clean Architecture (domain
must not contain implementations, only contracts); it was moved to the data
layer as part of this update.

### Data — `lib/features/books/data/`

| File | Purpose |
|---|---|
| `models/book_model.dart` | `BookModel` — `fromJson`/`toJson`/`toEntity()`. Isolates the on-the-wire JSON shape from the domain `Book`, so a backend field rename only touches this file |
| `datasources/book_local_datasource.dart` | Abstract `BookLocalDataSource` + `BookLocalDataSourceImpl`. Loads `assets/data/books.json` via `rootBundle`, decodes it, and maps to `BookModel` — deliberately built via `fromJson` from decoded JSON so swapping in a real `ApiBookDataSource` later is a drop-in, not a rewrite |
| `repositories/book_repository_impl.dart` | `BookRepositoryImpl implements BookRepository` — depends on `BookLocalDataSource`, catches datasource exceptions (`NotFoundException`, etc.) and maps them to `Left(Failure)` instead of letting them propagate |

`datasources/book_mock_datasource.dart` (the original name for this file)
has been deleted — it was a straight duplicate of `book_local_datasource.dart`
once the rename happened, and nothing referenced it anymore.

### Functional core — `lib/core/`

| File | Purpose |
|---|---|
| `error/failure.dart` | `Failure` base + `ServerFailure` / `NotFoundFailure` / `UnexpectedFailure` |
| `error/exceptions.dart` | `NotFoundException` / `UnexpectedException` — thrown by data sources only; the repository is what maps these into domain-level `Failure`s |
| `usecase/usecase.dart` | Generic `UseCase<Result, Params>` — `call(Params) → Future<Either<Failure, Result>>`; `NoParams` for use cases that take nothing |

- **Dependency**: `fpdart` — supplies `Either`/`Right`/`Left` used throughout
  the repository and use-case layers. Failures are values, not thrown
  exceptions, once they cross the repository boundary.

### Presentation — `lib/features/books/presentation/`

#### Providers — `providers/book_providers.dart`

The composition root, now generated via `riverpod_annotation`/
`riverpod_generator` (`part 'book_providers.g.dart';`) instead of manual
`Provider(...)` wiring:

| Provider | Kind | Purpose |
|---|---|---|
| `bookLocalDataSourceProvider` | `@riverpod` function | Constructs `BookLocalDataSourceImpl()` |
| `bookRepositoryProvider` | `@riverpod` function | `BookRepositoryImpl(ref.read(bookLocalDataSourceProvider))` |
| `getBooksUseCaseProvider`, `getBookByIdUseCaseProvider` | `@riverpod` function | Construct `GetBooks`/`GetBookById` over `bookRepositoryProvider` |
| `bookListProvider` | `@riverpod class BookList extends _$BookList` (`AsyncNotifier`) | Runs `GetBooks()` once, caches the list; `.match()` unwraps the `Either` right here so screens only ever see a plain `AsyncValue<List<Book>>` |
| `bookByIdProvider(id)` | `@riverpod` function, `.family` | Runs `GetBookById(id)`, same `Either` unwrap |

Screens never construct a repository or data source themselves — they only
`ref.watch`/`ref.invalidate` these providers. Swapping the data source (mock
list → bundled JSON → future remote API) is a one-line change here, nothing
downstream.

#### Screens — `screens/`

| File | Purpose |
|---|---|
| `books_screen.dart` | Home list screen, `ConsumerStatefulWidget` watching `bookListProvider`. Renders: a wired search field (filters in-memory, shows top 3 matches inline with a "See All" → `BookSearchResultsScreen`), a **Newest Picks** horizontal rail (books sorted by `publishedYear` descending, up to 10, via `BookVerticalCard`), a reminder banner for the soonest-due borrowed book, and a **Recommended for You** horizontal rail (up to 10 books). Both rails were bumped from 3 to 10 items so there's actually enough content to scroll horizontally |
| `book_details_screen.dart` | `ConsumerWidget` driven by `bookByIdProvider(bookId)`; same `AsyncValue.when` loading/error/data pattern, `AppButton` for Borrow (no-op placeholder — Borrowings feature doesn't exist yet) |
| `book_search_results_screen.dart` | Full search results. Watches `bookListProvider` directly instead of taking the list as a constructor argument — since the provider caches its result, this reuses the exact fetch `BooksScreen` already triggered rather than re-fetching or threading data through navigation. Renders matches as `BookCard` rows |

#### Widgets — `widgets/`

| File | Purpose |
|---|---|
| `book_card.dart` | Full-width row card (placeholder cover box + title/author/status badge). **No longer dead code** — used for the inline quick-search preview on `books_screen.dart` and the full list on `book_search_results_screen.dart` |
| `book_vertical_card.dart` | Fixed-width (110) portrait tile used in the horizontal rails — cover area, title, author, optional "Due in N days" indicator. The cover area is `Expanded` rather than a fixed height, so the same widget renders correctly under both the 200px (reminder rail) and 180px (recommended rail) parent constraints it's used in |

### Cover images

- `Book`, `BookModel`, and `books.json` now carry an optional `imageUrl`/`image`
  field. The bundled data uses Open Library ISBN cover URLs, for example
  `https://covers.openlibrary.org/b/isbn/...-L.jpg`.
- `BookCoverImage` renders the URL with Flutter's `Image.network`, using
  `BoxFit.cover`, a responsive `cacheWidth`, and a fallback placeholder while
  the image is loading or if the request fails.
- The old single `assets/images/book cover.jpg` photo is not used for book
  cards. It remains on disk and registered as an asset only until the unused
  asset cleanup is completed.

## Bugs found and fixed

From the original build:

- **`pubspec.yaml` had no `assets:` section at all** — `assets/data/books.json`
  and `assets/images/book cover.jpg` were never bundled into the app, so
  `rootBundle.loadString(...)` failed regardless of the path being correct.
- **Path mismatch** — the data source originally pointed at
  `assets/mock_data/books.json`; the real file lives at `assets/data/books.json`.
- **`id` type mismatch** — `books.json` stores `id` as a JSON number, but
  `BookModel.fromJson` did `json['id'] as String`, and
  `Book`/`BookRepository`/`GetBookById` all use `String` ids throughout.
  Fixed by parsing with `json['id'].toString()`; the by-id lookup
  (`b['id'] == id`) had the same mismatch and needed the same fix.

From the Riverpod/search conversion:

- **Repository wired to the wrong data source type** — `BookRepositoryImpl`
  still depended on the old `BookMockDataSource` class after
  `book_providers.dart` was switched to construct it from
  `bookLocalDataSourceProvider` (type `BookLocalDataSource`). Fixed by
  retyping the repository's field to the `BookLocalDataSource` interface.
- **`GetBooks.call` broke its `UseCase` override** — an edit dropped the
  `Params` parameter entirely (`call()` instead of
  `call([NoParams params = const NoParams()])`), which no longer satisfied
  `UseCase<Result, Params>.call(Params params)`. Restored the default-valued
  parameter.
- **Stale provider name** — `books_screen.dart` and
  `book_search_results_screen.dart` still watched/invalidated `booksProvider`,
  the old manual `FutureProvider`'s name; the codegen'd `BookList` class
  generates `bookListProvider` instead. Both call sites updated.
- **`BookSearchResultsScreen` constructor mismatch** mid-migration — it
  briefly required an `allBooks` argument no caller passed, then (after a
  fix in the wrong direction) briefly had `allBooks` passed to a constructor
  that no longer accepted it, once the screen was changed to watch
  `bookListProvider` directly instead of taking the list as a param. Settled
  on: no `allBooks` param, screen fetches via the provider itself.
- **`BookVerticalCard` vertical overflow** — the cover `Container` used a
  fixed `height: 135`, but the widget is placed inside two different
  parent heights (200px and 180px `SizedBox`es) depending on which rail
  renders it; the shorter one didn't leave enough room for the text block
  below, overflowing the `Column`. Fixed by making the cover `Expanded`
  instead of fixed-height, so it fills whatever space the text block
  doesn't need.
- **Every book showed the same cover photo** — see "Cover images" above.
- **Book covers initially remained blank after the URL implementation** — the
  model/data field was present, but the cover widget still rendered only the
  placeholder. `BookCoverImage` was updated to load `Book.imageUrl` through
  `Image.network`; the Android app also declares the `INTERNET` permission.
- **A cached-network-image experiment hid all failures** — the temporary
  `CachedNetworkImage` implementation used empty loading and error widgets,
  making network failures indistinguishable from missing images. It was
  removed and the native `Image.network` implementation restored.

## Decisions made

- **Errors are values (`Either<Failure, T>`) up to the provider boundary,
  not exceptions.** Only the data source is allowed to throw; the
  repository implementation is the single place that catches and converts
  to `Failure`; the `@riverpod` providers `.match()` the `Either` once and
  hand plain values (or a thrown error, for `AsyncValue` to catch) to the UI.
- **`UseCase<Result, Params>` is generic over params, not just zero-arg** —
  `GetBooks` uses `NoParams`, `GetBookById` uses `String` directly, so the
  same base class covers both shapes without a marker interface per case.
- **DI now runs through `riverpod_generator`, not manual construction.**
  Screens no longer build `GetBooks(BookRepositoryImpl(...))` inline; the
  composition root lives entirely in `book_providers.dart`.
- **Repository implementations live in `data/`, not `domain/`** — moved to
  match the Dependency Rule (domain defines the contract, data implements
  it), rather than the reverse.
- **`BookCard` is in active use, not dead code** — it's the row-style
  layout for search contexts (`books_screen.dart`'s inline quick-match list
  and the full `book_search_results_screen.dart`), while `BookVerticalCard`
  is the tile layout for the horizontal rails. Two different widgets for
  two different list shapes, not a superseded/replacement pair.
- **"Currently Borrowed" rail replaced by "Newest Picks"** (books sorted by
  `publishedYear` descending) — the reminder banner beneath it still reads
  from the same temporary mocked borrowed-preview (first 3 books,
  hardcoded `[2, 2, 1]` due-day list), since there's no real Borrowings
  feature yet to source it from.
- **Horizontal rails show up to 10 books, not 3** — with only 3 items, the
  rail's content fit within the viewport width and there was nothing to
  scroll; bumped both rails so horizontal scrolling has enough content to
  demonstrate.
- **Network covers use size-aware Open Library URLs** — `BookCoverImage`
  requests S, M, or L cover variants based on the rendered pixel width, while
  keeping the generic placeholder behind the network image.

## Open items for later phases

- Cover URLs currently depend on Open Library availability and network access;
  a production app should define an offline cache/fallback policy and handle
  provider rate limits or unavailable ISBN covers.
- `assets/images/book cover.jpg` is now fully unused — remove the asset and
  its `pubspec.yaml` entry, or find a real use for it.
- The reminder banner's "currently borrowed" data is still hardcoded mock
  content (first 3 books off the list, fixed due-day numbers) — needs a
  real Borrowings feature/provider to replace it.
- `main.dart`'s Borrowings/Profile bottom-nav tabs are still placeholder
  no-ops (`_todo(...)` snackbars) — those features don't exist yet, though
  `lib/features/borrowings/`, `lib/features/members/`, and
  `lib/features/auth/` are scaffolded (empty, `.gitkeep`-only) for them.
- `lib/features/splash/splash_screen.dart` exists and is wired to compile,
  but `main.dart` still points `home:` at `BooksScreen` with the
  `SplashScreen` line commented out — not yet part of the actual navigation
  flow.

## Next phase

With Riverpod/DI and Search now done (previously this section's proposed
"Phase 3"), the next candidates are: a real **Borrowings** feature (to
replace the mocked reminder-banner data and the placeholder bottom-nav tab),
wiring the **Splash** screen into actual app startup, or **Auth** — all
three currently exist only as empty scaffolding.
