# Pillar 3: Widget-Level Error Boundaries

[← Back to index](./README.md)

**What it is:** Flutter has no built-in per-widget try/catch like React's `ErrorBoundary`, but the same containment is achieved with patterns: wrapping a risky subtree's `build()` in try/catch and returning a fallback widget on failure, scoping an `ErrorWidget.builder` override to one subtree, or using state-holder patterns — notably Riverpod's `AsyncValue.when(data:, error:, loading:)` — so one failing widget shows an inline error instead of taking the whole screen down.

**Why it matters:** contains a failure to the smallest possible surface (one broken list tile or card) instead of letting a single bug crash an entire screen or the whole app. This app already uses `AsyncValue.when(...)` extensively — these exercises show what's protecting you today, and what breaks if that protection is removed.

## Exercises

### 1. Nested `.when()` isolates a borrowings-fetch failure on the Books screen

- **Pillar:** Widget-Level Error Boundaries
- **Where:** [lib/features/books/presentation/screens/books_screen.dart](../lib/features/books/presentation/screens/books_screen.dart), `build()`.
- **Description:** the Books screen watches two providers: `bookListProvider` (outer) and `myBorrowingsProvider` (inner, nested inside the outer `data:` branch).
- **Current (working) code:**
  ```dart
  body: asyncBooks.when(
    loading: () => const LoadingView(),
    error: (err, stack) => ErrorStateView(
      error: err,
      onRetry: () => ref.invalidate(bookListProvider),
    ),
    data: (books) {
      final asyncBorrowings = ref.watch(myBorrowingsProvider);
      return asyncBorrowings.when(
        loading: () => _buildContent(books, const []),
        error: (_, _) => _buildContent(books, const []),
        data: (borrowings) => _buildContent(books, borrowings),
      );
    },
  ),
  ```
  Because the inner `.when()` has its own `error:` branch, a failure fetching borrowings just renders the books list with an empty borrowings list (no "due soon" reminder banner, nothing marked "already borrowed") — the failure never reaches the outer `.when()`.
- **The break:** collapse the inner `.when()` into a force-unwrap, so a borrowings failure propagates instead of being contained:
  ```dart
  data: (books) {
    final borrowings = ref.watch(myBorrowingsProvider).value!;
    return _buildContent(books, borrowings);
  },
  ```
- **Reproduce:** make `myBorrowingsProvider` throw (e.g. temporarily throw inside its fetch method, or simulate by disconnecting whatever data source it reads from), then open the Books tab.
- **Expected symptom:** instead of the books list rendering normally without the reminder banner, the whole Books tab shows a red error screen / `Null check operator used on a null value` (since `.value` is `null` while the provider is in an error or loading state).
- **The fix:** restore the nested `.when()` shown above.

### 2. Per-row boundary in My Borrowings

- **Pillar:** Widget-Level Error Boundaries
- **Where:** [lib/features/borrowings/presentation/screens/my_borrowings_screen.dart](../lib/features/borrowings/presentation/screens/my_borrowings_screen.dart), `build()`.
- **Description:** similarly, `asyncBooks.when(...)` is nested inside `asyncBorrowings.when(...)`'s `data:` branch:
  ```dart
  data: (borrowings) {
    ...
    return asyncBooks.when(
      loading: () => const LoadingView(),
      error: (e, _) => const Center(
        child: Text('Could not load book details.', style: AppTextStyles.bodyMd),
      ),
      data: (books) { ... },
    );
  },
  ```
  If `bookListProvider` fails here, only the body under the "My Borrowings" app bar and tab bar is replaced with a small inline message — the scaffold, app bar, and tab bar stay intact.
- **The break:** replace the inner `error:` branch with something that rethrows the underlying error instead of containing it, e.g.:
  ```dart
  error: (e, _) => throw e!,
  ```
- **Reproduce:** make `bookListProvider` throw, then navigate to My Borrowings.
- **Expected symptom:** the entire My Borrowings screen shows a red error screen instead of the tab bar plus a small "Could not load book details." message.
- **The fix:** restore the original inner `error:` branch shown above.

---
[← Previous: Global Error Handling](./global-error-handling.md) · [Back to index](./README.md) · [Next: Async Errors →](./async-errors.md)
