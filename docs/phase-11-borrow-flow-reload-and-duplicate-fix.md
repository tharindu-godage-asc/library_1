# Phase 11 — Borrow/Return Flow: Reload Flash, Image-Ready Reveal, Duplicate Borrow

## Objective

Three related bugs in the Book Details / Borrowing Details / success-sheet
flow, found and fixed in one pass because they share root causes in the same
few files:

1. After a successful borrow or return, the details screen visibly flashed
   back to a loading spinner and rebuilt right as the success sheet popped
   up over it.
2. The cover image on both details screens (and inside the success sheet)
   popped in over a placeholder icon ~300ms after the rest of the content
   was already showing, instead of being ready when content first appears.
3. A member could borrow the same book title multiple times concurrently —
   nothing in the app ever checked "does this member already have this book
   borrowed?" — and even after that was fixed, the Borrow button could
   briefly flash back to an enabled "Borrow" state right after a successful
   borrow, before settling on "Already borrowed".

## What was built

### Reload flash — `skipLoadingOnReload`

Root cause: `BorrowActionController.borrow()` and
`ReturnActionController.returnBook()`
(`lib/features/borrowings/presentation/providers/borrowing_providers.dart`)
call `ref.invalidate(bookByIdProvider(...))` (and, for returns, also
`borrowingByIdProvider(...)`) right after a successful action. Riverpod's
`AsyncValue.when()` defaults `skipLoadingOnReload` to `false`, so an
invalidate-triggered refetch re-enters the `loading:` branch and the screen
drops back to `LoadingView()` mid-rebuild.

Fix: added `skipLoadingOnReload: true` to every `asyncBook`/`asyncBorrowing`
`.when(...)` call in `book_details_screen.dart` and
`borrowing_details_screen.dart` (the latter needs it on both its outer
`borrowingByIdProvider` `.when()` and its nested `bookByIdProvider`
`.when()` — both get invalidated on a successful return). The screen now
keeps rendering its already-loaded content while the invalidated provider
refetches silently in the background.

### Image-ready reveal — `BookCoverImage.precache`

`BookCoverImage` (`lib/features/books/presentation/widgets/book_cover_image.dart`)
always rendered a placeholder icon immediately and cross-faded the real
cover in once `Image.network` decoded it — fine for a list/card context, but
on a details screen or the success sheet it meant content appeared, then the
cover popped in a beat later.

- Promoted the private cover-sizing helper to `BookCoverImage.sizedUrl(url, targetWidthPx)`
  (same Open Library S/M/L bucketing logic, just public now).
- Added `BookCoverImage.precache(context, book, {required width, timeout})`:
  builds the *exact* `ResizeImage.resizeIfNeeded(targetWidthPx, null, NetworkImage(...))`
  that `Image.network(..., cacheWidth: ...)` builds internally (verified
  against the installed Flutter SDK, `packages/flutter/lib/src/widgets/image.dart:471-479`),
  so precaching it lands the same `ImageCache` key and the real widget later
  resolves with `wasSynchronouslyLoaded: true` — no fade needed. Bounded by
  a `timeout` (defensive only; `precacheImage` itself never completes with
  an error, per the Flutter SDK).
- `BookDetailsScreen` and `BorrowingDetailsScreen` converted from
  `ConsumerWidget` to `ConsumerStatefulWidget` to hold per-instance
  `_coverReadyKey`/`_precachingKey` state. A new `_ensureCoverPrecached(book)`
  kicks off `precache` once per distinct `book.imageUrl` (guarded so it
  never re-runs on unrelated rebuilds) and the `data` branch of the
  `.when()` call returns `LoadingView()` until `_coverReadyKey` matches the
  current book's `imageUrl` — a book with no cover image never blocks.
  `_coverWidth` constants (140 on Book Details, 44 on Borrowing Details)
  are shared between the precache call and the actual `SizedBox` so they
  can't drift apart.
- `BookActionSuccessSheet.show` (`lib/core/widgets/book_action_success_snackbar.dart`)
  is now `Future<void>` (async): it `await`s `BookCoverImage.precache(...)`
  at the sheet's actual cover size — pulled out into a shared
  `_coverBoxSize(context)` helper used by both `show()` and
  `BookActionSuccessSnackBar.build()` so the two can't disagree — before
  calling `showModalBottomSheet`, guarded by `if (!context.mounted) return;`
  in case the caller navigated away mid-await. Both call sites
  (`book_details_screen.dart`, `borrowing_details_screen.dart`) still call
  it fire-and-forget from inside `ref.listen`, wrapped in `unawaited(...)`
  for clarity — a `ref.listen` callback can't itself be usefully `async`.

### Duplicate borrowing of the same title

Root cause, confirmed by reading
`lib/features/borrowings/domain/usecases/borrow_book.dart`: `BorrowBook.call()`
checked the book had `availableCopies > 0` and the member's *total* active
borrowings were `< 3`, but never checked whether the member already held an
active borrowing of *this specific* book. `Book.isAvailable` is a real,
correctly-updated stock count (`availableCopies`) — not a stale flag — so a
multi-copy title happily let the same member "borrow" it several times over.
Nothing at the datasource/repository layer validated uniqueness either.

- Added `AlreadyBorrowedFailure` to `lib/core/error/failure.dart`, and to
  the business-rule arm of the exhaustive `Failure → AppErrorType` switch in
  `lib/core/error/app_error_type.dart` (that switch is deliberately
  non-exhaustive-safe — adding a `Failure` subtype without mapping it here
  is a compile error by design, which is exactly what caught this).
- `BorrowBook.call()` now reuses the member's borrowing list it already
  fetches (for the 3-active-borrowings check) to also reject a second active
  borrowing of the same `bookId`, before the count check.
- `BookDetailsScreen` now also watches `myBorrowingsProvider` (fails-soft,
  same pattern `books_screen.dart` already uses for its reminder banner —
  doesn't block the whole screen on this secondary fetch) and disables the
  Borrow button, relabelled "Already borrowed", when the member already
  holds an active borrowing of that book.
- **Follow-up fix:** `BorrowActionController.borrow()` flips
  `actionState.isLoading` back to `false` (re-enabling the button)
  synchronously on success, before the `ref.invalidate(myBorrowingsProvider)`
  it also fires has actually refetched — leaving a real window where the
  button could flash back to an enabled "Borrow" right as the success sheet
  was starting to show. Considered gating the button on the sheet's
  dismissal instead, and rejected it — the sheet can stay open for its full
  3s auto-dismiss, and there's no reason to keep the button inert that long
  once the borrow already succeeded. Fixed instead with a local
  `_justBorrowed` flag, set via `setState` the instant `ref.listen` sees the
  borrow succeed (same moment the success sheet starts its own
  precache-before-show sequence) — the button now goes directly from its
  loading spinner to disabled/"Already borrowed" with no gap, independent of
  both the sheet's and the provider's own timing.

## Files changed

- `lib/core/error/failure.dart` — new `AlreadyBorrowedFailure`.
- `lib/core/error/app_error_type.dart` — mapped it into the exhaustive switch.
- `lib/features/borrowings/domain/usecases/borrow_book.dart` — per-title duplicate check.
- `lib/features/books/presentation/widgets/book_cover_image.dart` — public `sizedUrl`, new `precache`.
- `lib/features/books/presentation/screens/book_details_screen.dart` — `ConsumerStatefulWidget`, `skipLoadingOnReload`, image-ready gating, `myBorrowingsProvider`-driven button guard, `_justBorrowed`.
- `lib/features/borrowings/presentation/screens/borrowing_details_screen.dart` — same `ConsumerStatefulWidget`/`skipLoadingOnReload`/image-ready gating treatment.
- `lib/core/widgets/book_action_success_snackbar.dart` — async `show()`, shared `_coverBoxSize`, precache-before-open.
- `test/features/books/book_cover_image_test.dart` — new unit test for `sizedUrl`'s S/M/L bucketing.

## Files to check/refer to for related future work

- `lib/features/borrowings/presentation/providers/borrowing_providers.dart` — where `BorrowActionController`/`ReturnActionController` live; any new action that invalidates a provider a details screen watches needs the same `skipLoadingOnReload` treatment on that screen's `.when()`, or it'll get this same reload-flash bug.
- `lib/features/books/domain/entities/book.dart` — `availableCopies`/`isAvailable`/`totalCopies` is the actual stock model; don't reintroduce a boolean-only availability check.
- `lib/features/borrowings/domain/entities/borrowing.dart` — `BorrowingStatus` enum; "active" everywhere in this phase means `status != BorrowingStatus.returned`.
- `lib/features/borrowings/domain/repositories/borrowing_repository.dart` — `getBorrowingsForMember` is the one call every duplicate/limit check in `BorrowBook` relies on; still no datasource/repository-level uniqueness enforcement, only usecase-level.
- Riverpod's `AsyncValue.when()` signature (`riverpod-3.4.3/lib/src/core/async_value.dart` in the pub cache) for the exact `skipLoadingOnReload`/`skipLoadingOnRefresh` semantics if another screen needs the same fix.
- Flutter SDK's `Image.network` constructor (`packages/flutter/lib/src/widgets/image.dart`) — the source of truth for how `BookCoverImage.precache`'s `ResizeImage.resizeIfNeeded(...)` call must stay in sync with `Image.network(..., cacheWidth: ...)` if that widget's image-loading code ever changes.
- `lib/features/books/presentation/screens/books_screen.dart` — the pre-existing "fails-soft secondary provider" pattern (`ref.watch(myBorrowingsProvider)` inside a `data` branch, not blocking on it) that `book_details_screen.dart` now also follows; keep new cross-feature reads consistent with it.

## Decisions made

- Local optimistic `_justBorrowed` flag over gating the button on the
  success sheet's dismissal — see the follow-up fix above for the reasoning
  (don't hold the button inert for the sheet's full lifetime).
- Precache keyed on `book.imageUrl`, not `bookId` — if a reload ever
  returned a different image for the same book (not expected from a borrow,
  which doesn't touch cover art, but not precluded by the domain model), the
  gate correctly re-engages instead of silently showing a stale cover.
- No duplicate-firing guard added for `ref.listen`/the success sheet:
  `ref.listen` only fires on genuine state transitions and both action
  controllers are `autoDispose`, so no concrete double-fire path exists —
  didn't add speculative guards for it.
- Each of the three `BookCoverImage.precache` call sites (Book Details
  @140px, Borrowing Details @44px, the success sheet @ its own computed
  width) precaches independently at its own on-screen size rather than
  trying to coordinate a shared size — Open Library's S/M/L buckets are
  coarse enough that two often land on the same request anyway (fast cache
  hit), and when they don't, each pays its own small, timeout-bounded cost.

## Open items for later phases

- No automated widget tests cover the `ConsumerStatefulWidget` conversions
  or the precache-gating/reload-flash fixes directly (the existing test
  suite has no provider-override or network-image-mocking infrastructure —
  see `test/widget_test.dart`, `test/features/books/book_vertical_card_test.dart`).
  Only the pure `BookCoverImage.sizedUrl` logic got a unit test this phase.
- The "at most one active borrowing per title per member" rule is enforced
  only in `BorrowBook` (the usecase) — still nothing at the
  `BorrowingLocalDataSourceImpl`/`BorrowingRepositoryImpl` layer. Acceptable
  today since this app has exactly one usecase path to create a
  `Borrowing`, but worth strengthening if a second creation path is ever
  added.
- Manual on-device verification of all of the above (image reveal timing,
  reload-flash absence, button flicker absence) is still pending — see
  Testing below.

## Testing

- `flutter analyze` — clean.
- `flutter test` — full suite passes (10/10), including the new
  `book_cover_image_test.dart`.
- Manual verification not performed by the assistant (per this project's
  no-manual-device-testing convention); still to be checked by the user:
  1. Book Details on a fresh navigation — spinner holds until the cover is
     fully rendered, no placeholder-then-pop.
  2. Borrow a book — success sheet's cover already rendered when it
     appears; the underlying Book Details screen doesn't flash back to a
     spinner while the sheet is showing or after it's dismissed; the Borrow
     button goes straight from its loading spinner to disabled/"Already
     borrowed" with no intermediate enabled-"Borrow" frame.
  3. Same checks for Borrowing Details / the return flow.
  4. A book with no cover image — both screens/the sheet still render
     immediately.
  5. Try to borrow an already-borrowed title again — button disabled, and
     if bypassed, a clear "You already have this borrowed" error surfaces
     instead of a second `Borrowing` record.
  6. Borrow up to the existing 3-active-borrowings limit on different
     titles — confirm that check still fires correctly.

## Next phase

Candidates: add widget-test infrastructure (provider overrides,
network-image mocking) so the reload-flash/image-gating/button-flicker
fixes in this phase get real regression coverage instead of relying on
manual verification; or move the duplicate-borrow uniqueness check down to
the repository/datasource layer for defense-in-depth.
