# Pillar 4: Async Errors

[← Back to index](./README.md)

**What it is:** errors occurring inside `Future`s, `async`/`await` code, or `Stream`s — an unhandled `Future` rejection, an exception thrown in a `.then()` callback with no `.catchError`, a missing `try/catch` around an `await`, an "unawaited" future whose error is silently dropped, an unhandled `Stream` error event, or a Riverpod `AsyncValue.error` state when a provider's async computation throws.

**Why it matters:** async errors are notorious for surfacing far from where they were caused — or not surfacing at all in a fire-and-forget future — making this the category most worth deliberately practicing rather than reading about.

## Exercises

### 1. An error inside `unawaited()` disappears silently

- **Pillar:** Async Errors
- **Where:** [lib/core/widgets/book_action_success_snackbar.dart](../lib/core/widgets/book_action_success_snackbar.dart), called via `unawaited(BookActionSuccessSheet.show(...))` in both [book_details_screen.dart](../lib/features/books/presentation/screens/book_details_screen.dart) (after a successful borrow) and [borrowing_details_screen.dart](../lib/features/borrowings/presentation/screens/borrowing_details_screen.dart) (after a successful return).
- **Description:** `unawaited()` from `dart:async` is a lint-satisfying marker meaning "yes, I intentionally didn't await this Future" — it does **not** catch or suppress errors. If `BookActionSuccessSheet.show()` throws, the exception still propagates, but because nothing awaits the Future, it only ever surfaces as an unhandled async error in the current zone — a raw console dump (or nothing at all, if [Global Error Handling](./global-error-handling.md) isn't wired up) — never as something the `ref.listen` callback or the borrow flow can react to.
- **The break:** temporarily add a throw as the first line of `BookActionSuccessSheet.show`:
  ```dart
  static Future<void> show(
    BuildContext context, {
    required Book book,
    required String title,
    required String heading,
    required String message,
    required DateTime borrowedDate,
    required DateTime returnDate,
  }) async {
    throw Exception('boom - simulated failure');
    // ... rest of the method unchanged
  }
  ```
- **Reproduce:** borrow a book from the Book Details screen.
- **Expected symptom:** the borrow itself still appears to succeed (the button flips to "Already borrowed", the app behaves as if everything worked), but the success sheet never appears, and the console shows an unhandled exception with no connection back to the borrow action:
  ```
  Unhandled exception:
  Exception: boom - simulated failure
  ```
- **The fix:** remove the temporary `throw`. If a fire-and-forget call like this genuinely needs to react to failure, either await it inside a `try/catch`, or attach `.catchError(...)` to the future before wrapping it in `unawaited(...)`:
  ```dart
  unawaited(
    BookActionSuccessSheet.show(context, book: book, title: book.title, heading: 'Book Borrowed!',
        message: '...', borrowedDate: borrowing.borrowedDate, returnDate: borrowing.dueDate)
      .catchError((Object error, StackTrace stack) {
    debugPrint('Failed to show success sheet: $error');
  }));
  ```

### 2. A `.then()` chain with no `.catchError` swallows a precache failure

- **Pillar:** Async Errors
- **Where:** [lib/features/books/presentation/screens/book_details_screen.dart](../lib/features/books/presentation/screens/book_details_screen.dart), `_ensureCoverPrecached` (the identical pattern also exists in [borrowing_details_screen.dart](../lib/features/borrowings/presentation/screens/borrowing_details_screen.dart)).
- **Description:** current code:
  ```dart
  void _ensureCoverPrecached(Book book) {
    final key = book.imageUrl;
    if (key == null || _coverReadyKey == key || _precachingKey == key) return;
    _precachingKey = key;
    BookCoverImage.precache(context, book, width: _coverWidth).then((_) {
      if (!mounted) return;
      setState(() => _coverReadyKey = key);
    });
  }
  ```
  If `BookCoverImage.precache(...)` throws, there is no `.catchError` for that error to land in — it becomes an unhandled Future error. Worse, `_precachingKey` is never cleared on failure, so the widget is permanently stuck believing that key is "currently precaching" and will never retry.
- **The break:** point at a cover that fails to precache — e.g. temporarily hardcode a broken URL, or add `throw Exception('boom');` as the first line inside the `.then()` callback to simulate a downstream failure at that point.
- **Reproduce:** open a book detail screen for the affected book.
- **Expected symptom:** the screen stays on `LoadingView()` forever for that book (since `_coverReadyKey` is never set), and the console shows an unhandled exception disconnected from any visible UI feedback.
- **The fix:** remove the temporary throw/URL change, and add a `.catchError` that at minimum clears `_precachingKey` so a retry becomes possible:
  ```dart
  BookCoverImage.precache(context, book, width: _coverWidth).then((_) {
    if (!mounted) return;
    setState(() => _coverReadyKey = key);
  }).catchError((Object error, StackTrace stack) {
    if (!mounted) return;
    _precachingKey = null;
    debugPrint('Cover precache failed for $key: $error');
  });
  ```

---
[← Previous: Widget-Level Error Boundaries](./widget-error-boundaries.md) · [Back to index](./README.md)
