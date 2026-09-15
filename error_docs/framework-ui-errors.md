# Pillar 1: Flutter Framework & UI Errors

[← Back to index](./README.md)

**What it is:** errors thrown by the Flutter framework itself during the build/layout/paint pipeline — e.g. `A RenderFlex overflowed by N pixels`, `setState() or markNeedsBuild() called during build`, `setState() called after dispose()`, a missing required ancestor (`Directionality`, `Scaffold`, `MediaQuery`), duplicate `GlobalKey`s, or an infinite build loop.

**Why it matters:** this is the category most day-to-day Flutter errors fall into, and it's what produces the classic red-and-yellow "error screen" in debug mode. Learning to read that screen's anatomy (the widget, the exception summary, the "When the exception was thrown, this was the stack" section) is the single highest-leverage debugging skill for a Flutter developer.

## Exercises

### 1. RenderFlex overflow in `BookCard`

- **Pillar:** Flutter Framework & UI Errors
- **Where:** [lib/features/books/presentation/widgets/book_card.dart](../lib/features/books/presentation/widgets/book_card.dart)
- **Description:** `BookCard`'s `Row` puts a fixed-size cover image, a spacer, and the title/author column inside `Expanded`. `Expanded` is what tells the `Column` "take only the width left over in this Row" — without it, the `Column` sizes itself to its widest child's natural (unbounded) width, and a long enough title overflows the row.
- **Current (working) code:**
  ```dart
  Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(book.title, style: AppTextStyles.bodyLg, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(book.author, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xs),
        StatusBadge(status: book.isAvailable ? BadgeStatus.available : BadgeStatus.overdue),
      ],
    ),
  ),
  ```
- **The break:** remove the `Expanded` wrapper, leaving the bare `Column` directly inside the `Row`:
  ```dart
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(book.title, style: AppTextStyles.bodyLg, maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(book.author, style: AppTextStyles.caption),
      const SizedBox(height: AppSpacing.xs),
      StatusBadge(status: book.isAvailable ? BadgeStatus.available : BadgeStatus.overdue),
    ],
  ),
  ```
- **Reproduce:** run the app and open any screen that renders a `BookCard` with a reasonably long title (e.g. the Books tab search results) — the wider the title, the more obvious the overflow.
- **Expected symptom:** yellow-and-black "overflow" hazard stripes on the right edge of the card, plus a console error:
  ```
  A RenderFlex overflowed by 41 pixels on the right.
  The relevant error-causing widget was: Row ...
  ```
- **The fix:** put `Expanded` back around the `Column`, restoring the snippet above.

### 2. `setState() called after dispose()` in `BookDetailsScreen`

- **Pillar:** Flutter Framework & UI Errors
- **Where:** [lib/features/books/presentation/screens/book_details_screen.dart](../lib/features/books/presentation/screens/book_details_screen.dart), method `_ensureCoverPrecached`.
- **Description:** `_ensureCoverPrecached` kicks off an async image precache and calls `setState()` once it completes. Between the `await`/`.then()` and that callback running, the user can navigate away and the widget can be disposed — calling `setState()` on a disposed `State` throws. The existing `if (!mounted) return;` guard is the fix already in place; removing it re-introduces the bug.
- **Current (working) code:**
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
- **The break:** delete the `if (!mounted) return;` line:
  ```dart
  BookCoverImage.precache(context, book, width: _coverWidth).then((_) {
    setState(() => _coverReadyKey = key);
  });
  ```
- **Reproduce:** open a book whose cover takes a moment to load (throttle your network, or pick a book with a large/slow image), then navigate back to the Books tab immediately, before the cover finishes precaching.
- **Expected symptom:** once the precache completes after the screen is gone, a red error screen / console exception:
  ```
  FlutterError (setState() called after dispose(): _BookDetailsScreenState#...(lifecycle state: defunct, not mounted)
  This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree ...)
  ```
- **The fix:** restore the `if (!mounted) return;` guard before the `setState` call.

---
[← Back to index](./README.md) · [Next: Global Error Handling →](./global-error-handling.md)
