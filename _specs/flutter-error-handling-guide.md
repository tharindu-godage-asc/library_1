# Feature Spec: Flutter Error Handling Guide

branch: Learn-Error-Handling
spec: _specs/flutter-error-handling-guide.md
owner: tngodage
date: 2026-09-15

---

## 0) Summary

**One-liner:** A learning document, placed in an "error docs" folder in this repo, organized around four pillars of Flutter/Dart errors — Flutter Framework & UI Errors, Global Error Handling, Widget-Level Error Boundaries, and Async Errors — that explains each pillar and, for each one, walks through deliberately breaking something in this existing app to reproduce it, then shows the fix.
**Why now:** The user wants a hands-on, project-grounded way to learn how Flutter errors actually manifest (stack traces, red screens, silent failures) rather than reading about them abstractly, using this app's own codebase as the practice ground.
**Who is this for:** The app owner/developer (solo learner), as a personal reference while leveling up on Flutter error handling.
**Success looks like:** A markdown doc exists where each documented error type has (a) a plain-language explanation, (b) a concrete "break it" recipe using real files/widgets from this app, (c) the expected symptom (exception text, red screen, console output, etc.), and (d) the fix, restoring the app to its original working state.

---

## 1) Goals and Non-Goals

### Goals
- Produce a single well-organized markdown document (or a small set of them) under a new "error docs" folder in the repo.
- Teach the four pillars of Flutter/Dart errors, each with its own plain-language explanation before any exercises:
  1. **Flutter Framework & UI Errors** — errors the framework itself throws during build/layout/paint (e.g. `RenderFlex` overflow, `setState()` after `dispose()`, missing required ancestor widgets), typically surfaced as the red-and-yellow debug error screen.
  2. **Global Error Handling** — app-wide interception points (`FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded`, a custom `ErrorWidget.builder`) that catch errors before they crash the app silently or show Flutter's default red screen in release.
  3. **Widget-Level Error Boundaries** — patterns for containing a failure to a single widget/subtree instead of the whole screen (try/catch around a risky `build()`, scoped `ErrorWidget.builder` overrides, `AsyncValue.when(data:, error:, loading:)` in Riverpod).
  4. **Async Errors** — errors inside `Future`/`async`-`await`/`Stream` code: unhandled Future rejections, missing `try/catch` around an `await`, unawaited futures that silently swallow errors, unhandled `Stream` error events, and Riverpod `AsyncValue.error` states.
- For each error type, use an actual file/widget/provider from this app as the demonstration subject, so the exercise is concrete rather than a generic snippet.
- Show a minimal, intentional code change that triggers the error, the exact error output the user should expect to see, and the corresponding fix that reverts the app to correct behavior.
- Leave the app in its original, working state after each demonstrated break/fix cycle — the doc is a guided exercise log, not a set of permanent code changes.

### Non-Goals
- Not building any new app feature, screen, or user-facing functionality.
- Not covering errors unrelated to Flutter/Dart (e.g. backend/server errors, CI/CD errors) unless they surface through this app's existing stack (Riverpod, go_router, etc.).
- Not an exhaustive academic reference of every possible Dart exception class — focus is on errors realistically encountered while building an app like this one.
- Not automated tests or lint rules — this is a learning document, not tooling.

---

## 2) User Workflow

### Primary workflow
1. User opens the error-docs folder and picks an error category they want to learn about.
2. The doc tells them which file in the app to open and what specific change to make to intentionally trigger that error.
3. User makes the change, runs the app, and observes the error (stack trace, red screen, console warning, etc.), comparing it against what the doc says to expect.
4. The doc then walks through diagnosing why the error happened and shows the exact fix.
5. User applies the fix, confirms the app returns to its normal working state, and moves on to the next error category.

### Secondary workflows (optional)
- User skims the doc's table of contents to jump directly to a specific error type they just encountered unexpectedly in real development, using it as a lookup/reference rather than a linear tutorial.

---

## 3) Document Structure (What the doc exposes)

### 3.1 The four pillars (learning content, one per top-level section)

Each pillar gets its own top-level section in the doc that opens with a plain-language explainer *before* any break/fix exercises:

1. **Flutter Framework & UI Errors**
   - What it is: errors thrown by the Flutter framework during the build/layout/paint pipeline — e.g. `A RenderFlex overflowed by N pixels`, `setState() or markNeedsBuild() called during build`, `setState() called after dispose()`, a missing required ancestor (`Directionality`, `Scaffold`, `MediaQuery`), duplicate `GlobalKey`s, or an infinite build loop.
   - Why it matters: this is the category most day-to-day Flutter errors fall into, and it's what produces the classic red-and-yellow "error screen" in debug mode. Learning to read that screen's anatomy (widget, exception summary, "when the exception was thrown" stack) is the single highest-leverage debugging skill for a Flutter developer.
2. **Global Error Handling**
   - What it is: app-wide hooks that intercept errors before they crash the app or disappear silently — `FlutterError.onError` (framework/build errors), `PlatformDispatcher.instance.onError` (uncaught errors at the root, including async ones), `runZonedGuarded` (wraps `main()` in a custom zone to catch anything else), and overriding `ErrorWidget.builder` to replace Flutter's red error box with a friendlier screen in release builds.
   - Why it matters: without these hooks, errors thrown outside the widget build phase (a callback, a timer, an isolate) can crash the app with zero record of what happened. This is also the layer where crash-reporting SDKs (e.g. Sentry, Firebase Crashlytics) plug in.
3. **Widget-Level Error Boundaries**
   - What it is: Flutter has no built-in per-widget try/catch like React's `ErrorBoundary`, but the same containment is achieved with patterns: wrapping a risky subtree's `build()` in try/catch and returning a fallback widget on failure, scoping an `ErrorWidget.builder` override to one subtree, or using state-holder patterns — notably Riverpod's `AsyncValue.when(data:, error:, loading:)` — so one failing widget shows an inline error instead of taking the whole screen down.
   - Why it matters: contains a failure to the smallest possible surface (one broken list tile or card) instead of letting a single bug crash an entire screen or the whole app.
4. **Async Errors**
   - What it is: errors occurring inside `Future`s, `async`/`await` code, or `Stream`s — an unhandled `Future` rejection, an exception thrown in a `.then()` callback with no `.catchError`, a missing `try/catch` around an `await`, an "unawaited" future whose error is silently dropped, an unhandled `Stream` error event, or a Riverpod `AsyncValue.error` state when a provider's async computation throws.
   - Why it matters: async errors are notorious for surfacing far from where they were caused — or not surfacing at all in a fire-and-forget future — making this the category most worth deliberately practicing rather than reading about.

### 3.2 Per-entry exercise template

Within each pillar's section, every concrete error entry follows this template:
- Name: (e.g. "Null Check Operator Used on a Null Value")
- Pillar: one of the four sections above
- Plain-language description: what the error means and why it happens
- Where in this app to reproduce it: exact file path and widget/function to modify
- The break: the specific, minimal change to introduce
- Expected symptom: the exact console output, exception message, or red-screen text to expect
- The fix: what to change and why it resolves the root cause
- Example calls: N/A (not a function/API being exposed — this is a documentation deliverable, not code)
- Errors/warnings behavior: covered per-entry above (this section IS about errors/warnings by design)

## 4) Data Contracts (DF schemas + join keys)

N/A — this feature is a documentation artifact, not a data-processing feature. There are no dataframes, inputs, or output schemas involved.

### 4.1 Inputs
N/A

### 4.2 Required columns (minimum contract)
N/A

### 4.3 Output schema
N/A — the "output" of this feature is the markdown document itself (see Section 3.1 for its structure).

## 5) Business Rules

### 5.1 Portfolio filtering
N/A — not applicable to this feature.

### 5.2 ITM/OTM classification
N/A — not applicable to this feature.

### 5.3 Pricing / Greeks
N/A — not applicable to this feature.

### 5.4 Scope of errors covered
- The doc is organized into exactly the four pillars from Section 3.1, in this order: Flutter Framework & UI Errors → Global Error Handling → Widget-Level Error Boundaries → Async Errors. This mirrors a natural learning progression: first recognize UI-level errors, then learn the app-wide safety net, then how to contain failures locally, then the trickiest category (async).
- Within each pillar, entries should be chosen based on what's realistically reachable in this app's existing codebase (Flutter widgets, Riverpod providers, go_router navigation, Dart null safety, async/await) so every exercise is grounded in a real file rather than a made-up snippet.
- Each "break" must be reversible with a clearly stated fix — the doc should never leave the reader unsure how to restore working code.
- Within a pillar, order entries from most fundamental to more advanced (e.g. within Async Errors: a missing `await`/`try-catch` before an unhandled `Stream` error before a Riverpod `AsyncValue.error` case).

## 6) Architecture (must match TECHNICAL_BLUEPRINT)

N/A — this is a documentation-only feature with no runtime code, clients, constants, utils, or orchestration layer to design. The only "artifact" produced is the markdown file(s) and the folder they live in.

### 6.1 clients/ (I/O boundary)
N/A

### 6.2 constants/ (values only)
N/A

### 6.3 utils/ (pure transforms, vectorized)
N/A

### 6.4 orchestration layer (e.g., recon/ or S****l entrypoints)
N/A

## 7) Edge Cases

- Some Framework & UI errors (e.g. layout overflow) are visually obvious in debug mode but silent/clipped in release mode — the doc should note this distinction where relevant.
- Global Error Handling hooks (`FlutterError.onError`, `PlatformDispatcher.instance.onError`, `runZonedGuarded`) can only be demonstrated meaningfully once, at `main()` — the doc should be clear that this pillar's exercises modify app bootstrap rather than a single screen.
- Widget-Level Error Boundary demos must show both the "before" (one bug crashes the whole screen) and "after" (the same bug is contained to one widget) side by side, or the lesson doesn't land.
- Async Error demos should distinguish errors that are silently swallowed (e.g. an un-awaited future) from ones that crash loudly, since the whole point of this pillar is that silent failures are the harder case to learn.
- Some errors only reproduce on certain platforms (e.g. a plugin error on Android but not iOS) — doc should flag platform-specific caveats where applicable.
- A "break" recipe must not require unrelated app setup (e.g. seeded backend data) that the reader may not have — prefer breaks reachable from the app's UI in its current state.
- If a break requires temporarily commenting out error-handling code that exists for good reason (e.g. a try/catch), the doc must explicitly say to restore it afterward.

## 8) Acceptance Criteria

Checklist that can be tested:
- [ ] A markdown document (or small set of documents) exists under a clearly named "error docs" folder in the repo root.
- [ ] The doc has four top-level sections, one per pillar: Flutter Framework & UI Errors, Global Error Handling, Widget-Level Error Boundaries, Async Errors — each opening with a plain-language explainer before any exercises.
- [ ] Every pillar has at least one concrete break/fix exercise grounded in a real file from this app.
- [ ] Every documented error entry includes: description, exact file/change to reproduce it in this app, expected symptom, and fix.
- [ ] Following any single entry in the doc, start to finish, leaves the app compiling and running exactly as it did before.
- [ ] The doc is organized with a table of contents so entries can be used as a linear tutorial or a quick lookup reference.

## 9) Test Plan

### 9.1 Golden fixture (required)
N/A — no data fixtures involved. Verification instead means: for a sample of entries in the doc, actually perform the break/fix cycle in the running app and confirm the observed output matches what the doc describes.

### 9.2 Unit tests (utils/)
N/A — no utils/code produced by this feature.

### 9.3 Integration tests (orchestration)
N/A — verification is manual, as described in 9.1.

## 10) References Used (required)

- This app's existing codebase (Flutter, Riverpod, go_router) as the source of concrete files/widgets used in each "break it" exercise.
- _specs/template.md: structure followed for this spec (with data/pipeline-specific sections marked N/A where they don't apply to a documentation feature).

## 11) Open Questions

- Q: Should the "error docs" folder live at the repo root (e.g. `error_docs/`) or nested under an existing docs location? Use the folder I have created
  - Decision owner / date: tngodage — TBD before implementation begins.
- Q: Should this be one long markdown file, or one file per error category for easier navigation? 1 file per error category
  - Decision owner / date: tngodage — TBD before implementation begins.
- Q: Should "breaking the app" exercises be left as literal step-by-step instructions only, or should the doc also include a checked-in "before/after" git diff or branch per exercise? Do both
  - Decision owner / date: tngodage — TBD before implementation begins.
