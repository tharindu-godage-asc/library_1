# Error Handling Fixes to Port to `dev`

This is a checklist of the concrete, permanent error-handling improvements developed while working through the [Flutter Error Handling Guide](./README.md) on the `Learn-Error-Handling` branch. Everything else touched during those exercises (the `book_card.dart` overflow, the `books_screen.dart` boundary break, etc.) was reverted back to match `dev` exactly — confirmed via `git diff dev`, no changes needed there.

Only two things are new and worth carrying over:

- [ ] **Global Error Handling** in `lib/main.dart`
- [ ] **Async error safety net** in the duplicated `_ensureCoverPrecached` method (2 files)

## 1. Global Error Handling — `lib/main.dart`

**Why:** today `dev`'s `main()` has zero error-interception hooks — any uncaught error outside a widget's `build()` (a timer, a callback, an async gap) disappears with only a raw, unstructured console dump, and in a release build you may not see it at all. This wires up the standard four hooks: `ErrorWidget.builder` (friendlier inline error UI), `FlutterError.onError` (framework/build errors), `PlatformDispatcher.instance.onError` (engine-level async errors), and `runZonedGuarded` (catches anything else uncaught in the zone `main()` runs in).

**Current (`dev`):**
```dart
void main() {
  runApp(const ProviderScope(child: LibraryApp()));
}
```

**Change to:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'dart:async';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Center(
      child: Text('Something went wrong displaying this.'),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In a real app, you might want to report the error to an error tracking service.
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught platform error: $error\n$stack');
    return true; // handled
  };

  runZonedGuarded(
    () => runApp(const ProviderScope(child: LibraryApp())),
    (Object error, StackTrace stack) {
      // Handle uncaught errors here. You might want to log them or report them to an error tracking service.
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}
```

**Note:** the `debugPrint(...)` calls and the plain-text `ErrorWidget.builder` message are placeholders — swap them for whatever crash-reporting SDK (Sentry, Firebase Crashlytics, etc.) or design-system error state the app ends up using in production.

**Verify:** see [global-error-handling.md](./global-error-handling.md) exercises 1–3 for how to trigger each hook deliberately and confirm it fires.

## 2. Async error safety net for cover precaching (2 files)

**Why:** `_ensureCoverPrecached` kicks off `BookCoverImage.precache(...).then((_) { ... })` with no `.catchError`. If precaching ever throws (bad URL, network failure not already handled inside `precache`), two things go wrong: the error becomes an unhandled Future rejection (silent/raw console dump), and `_precachingKey` is never cleared — so the screen gets stuck on `LoadingView()` for that book forever, with no way to retry. See [async-errors.md](./async-errors.md) exercise 2 for the full walkthrough.

**Files:**
- `lib/features/books/presentation/screens/book_details_screen.dart`
- `lib/features/borrowings/presentation/screens/borrowing_details_screen.dart`

Both have the identical method — apply the same change to both:

**Current (`dev`):**
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

**Change to:**
```dart
void _ensureCoverPrecached(Book book) {
  final key = book.imageUrl;
  if (key == null || _coverReadyKey == key || _precachingKey == key) return;
  _precachingKey = key;
  BookCoverImage.precache(context, book, width: _coverWidth).then((_) {
    if (!mounted) return;
    setState(() => _coverReadyKey = key);
  }).catchError((Object error, StackTrace stack) {
    if (!mounted) return;
    _precachingKey = null;
    debugPrint('Failed to precache book cover: $error');
  });
}
```

**Verify:** temporarily force `BookCoverImage.precache` to throw (or point at a bad URL), confirm the screen no longer gets stuck, and that `_precachingKey` being cleared lets a retry succeed. Remove the temporary failure afterward.
