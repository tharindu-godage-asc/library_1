# Flutter Error Handling Guide

A hands-on guide to Flutter/Dart errors, taught against **this app's own codebase**. Every exercise tells you an exact file to open, a small change that intentionally breaks something, what you should see when it breaks, and how to fix it back.

This is a practice log, not a reference to read passively — the value comes from actually making the break, running the app, reading the real error output, then applying the fix and confirming the app is back to normal.

See [_specs/flutter-error-handling-guide.md](../_specs/flutter-error-handling-guide.md) for the spec this guide was built from.

## The four pillars

1. [Flutter Framework & UI Errors](./framework-ui-errors.md) — errors the framework itself throws during build/layout/paint (overflow, `setState()` after `dispose()`, missing ancestors). The classic red-and-yellow debug error screen.
2. [Global Error Handling](./global-error-handling.md) — app-wide hooks (`FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded`, `ErrorWidget.builder`) that catch errors before they crash the app silently.
3. [Widget-Level Error Boundaries](./widget-error-boundaries.md) — containing a failure to one widget/subtree instead of the whole screen, using patterns like Riverpod's `AsyncValue.when(...)`.
4. [Async Errors](./async-errors.md) — errors inside `Future`/`async`-`await`/`Stream` code: unhandled rejections, missing `try/catch`, unawaited futures that swallow errors silently.

## How to use this guide

1. Pick a pillar above (or jump straight to an entry if you just hit an error you don't recognize).
2. Read the pillar's explainer first — it's the "why this category exists" context for every exercise underneath it.
3. Open the exact file the exercise names and make the described **break**.
4. Run the app and reproduce the **expected symptom** — compare it against what the entry says you should see.
5. Apply the **fix** and confirm the app compiles and behaves exactly as it did before you started.
6. Move on to the next entry, or come back later and use the table of contents as a lookup reference.

Every exercise is written to be fully reversible: nothing in this guide is meant to be a permanent code change to the app.

## Fixes worth keeping

Working through this guide surfaced two genuine, permanent improvements (not exercise artifacts) that this branch's `lib/` currently has but `dev` doesn't yet. See [dev-branch-fixes-checklist.md](./dev-branch-fixes-checklist.md) for the exact changes to port over.
