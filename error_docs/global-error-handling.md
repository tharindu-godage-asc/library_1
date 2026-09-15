# Pillar 2: Global Error Handling

[← Back to index](./README.md)

**What it is:** app-wide hooks that intercept errors before they crash the app or disappear silently — `FlutterError.onError` (framework/build errors), `PlatformDispatcher.instance.onError` (uncaught errors at the root, including async ones), `runZonedGuarded` (wraps `main()` in a custom zone to catch anything else), and overriding `ErrorWidget.builder` to replace Flutter's red error box with a friendlier screen in release builds.

**Why it matters:** without these hooks, errors thrown outside the widget build phase (a callback, a timer, an isolate) can crash the app with zero record of what happened. This is also the layer where crash-reporting SDKs (e.g. Sentry, Firebase Crashlytics) plug in.

**Starting point:** this app currently has none of these hooks wired up — [lib/main.dart](../lib/main.dart) is a bare `main()`:

```dart
void main() {
  runApp(const ProviderScope(child: LibraryApp()));
}
```

That means any uncaught error today — anywhere outside a widget's `build()` — only ever produces a raw, unstructured console dump, and in a release build you may not see anything at all.

## Exercises

### 1. Wiring up `runZonedGuarded` + `FlutterError.onError`

- **Pillar:** Global Error Handling
- **Where:** [lib/main.dart](../lib/main.dart)
- **Description:** see the gap first, then close it.
- **The break (see the gap):** temporarily add a fire-and-forget error near the top of `main()`, before `runApp`:
  ```dart
  void main() {
    Timer(Duration.zero, () => throw Exception('boom - simulated crash'));
    runApp(const ProviderScope(child: LibraryApp()));
  }
  ```
  (add `import 'dart:async';` for `Timer`).
- **Reproduce:** run the app.
- **Expected symptom:** the app still launches and looks fine, but the console shows an unstructured dump along the lines of:
  ```
  Unhandled exception:
  Exception: boom - simulated crash
  #0      main.<anonymous closure>
  ```
  There is no hook you could plug a crash reporter into — the error just prints and is gone.
- **The fix:** remove the temporary `Timer`, and wrap the app in `runZonedGuarded` with `FlutterError.onError` set:
  ```dart
  import 'dart:async';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'core/navigation/app_router.dart';
  import 'core/theme/app_theme.dart';

  void main() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // e.g. forward to a crash-reporting service here
    };

    runZonedGuarded(
      () => runApp(const ProviderScope(child: LibraryApp())),
      (Object error, StackTrace stack) {
        // e.g. forward to a crash-reporting service here
        debugPrint('Uncaught zone error: $error\n$stack');
      },
    );
  }
  ```
- **Verify the fix:** put the temporary `Timer(...)` throw back in *inside* the `runZonedGuarded` callback and confirm your `debugPrint` line now runs instead of the bare "Unhandled exception" dump. Then remove the temporary throw again — it was only there to prove the point.

### 2. `PlatformDispatcher.instance.onError` for engine-level async errors

- **Pillar:** Global Error Handling
- **Where:** [lib/main.dart](../lib/main.dart)
- **Description:** `runZonedGuarded` catches errors thrown inside the zone it wraps, but some errors (e.g. from platform channel callbacks or certain async engine callbacks) surface through `PlatformDispatcher.instance.onError` instead. Modern Flutter apps set both.
- **The break (see the gap):** with only the Exercise 1 fix in place (no `PlatformDispatcher.instance.onError`), it's harder to demonstrate a true platform-channel error without a native plugin, so treat this exercise as additive: confirm today's `main()` has no `PlatformDispatcher.instance.onError` set.
- **The fix:** add it alongside the Exercise 1 changes:
  ```dart
  void main() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('Uncaught platform error: $error\n$stack');
      return true; // handled
    };

    runZonedGuarded(
      () => runApp(const ProviderScope(child: LibraryApp())),
      (Object error, StackTrace stack) => debugPrint('Uncaught zone error: $error\n$stack'),
    );
  }
  ```
- **Expected symptom after the fix:** no visible behavior change during normal use — this is a safety net, not a feature. The value is only observed when something actually throws at that layer.

### 3. A friendlier `ErrorWidget.builder` for release builds

- **Pillar:** Global Error Handling
- **Where:** [lib/main.dart](../lib/main.dart)
- **Description:** even with the above hooks in place, a Framework & UI Error (see [Pillar 1](./framework-ui-errors.md)) still renders Flutter's default error widget inline in the tree where it happened. `ErrorWidget.builder` lets you replace that with something on-brand.
- **The break (see the default):** temporarily make a widget throw during build to see today's default error box, e.g. in `_SectionHeader.build` in [books_screen.dart](../lib/features/books/presentation/screens/books_screen.dart) add `throw Exception('boom');` as the first line.
- **Expected symptom:** Flutter's default red-bordered error box appears exactly where `_SectionHeader` would have rendered, showing the exception message.
- **The fix:** remove the temporary throw, and add near the top of `main()`:
  ```dart
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Center(
      child: Text('Something went wrong displaying this.'),
    );
  };
  ```
  Re-add the temporary throw to confirm your custom widget now appears instead of the default red box, then remove the throw again.

---
[← Previous: Flutter Framework & UI Errors](./framework-ui-errors.md) · [Back to index](./README.md) · [Next: Widget-Level Error Boundaries →](./widget-error-boundaries.md)
