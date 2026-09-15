# Phase 10 — Book Cover Loading and Android Runtime Verification

## Objective

Make the newly added per-book cover URLs visible in the app and verify that
the Android emulator, Flutter device discovery, and project toolchain are
healthy enough to run the application.

## What changed

- `BookModel.fromJson` reads the JSON `image` field into the domain entity's
  `imageUrl` property, and model serialization preserves it.
- `BookCoverImage` loads non-null cover URLs with Flutter's `Image.network`.
  It keeps the generic book-icon placeholder underneath, requests an Open
  Library S/M/L variant based on the rendered pixel width, and fades in a
  successfully decoded image.
- Failed or missing image requests fall back to the placeholder instead of
  breaking the book card.
- Android declares `android.permission.INTERNET`, which is required for the
  emulator build to retrieve Open Library covers.

## Regression fixed

A temporary `CachedNetworkImage` replacement made every failed request look
like a permanently empty placeholder because both its loading and error
builders returned `SizedBox.shrink()`. The implementation was reverted to
`Image.network`, which matches the previously working Flutter image path and
keeps the existing error fallback.

The cache package was removed after the experiment so the dependency list
matches the implementation.

## Emulator verification

The local environment was checked on 2026-09-14:

- `flutter devices` detected `sdk gphone16k x86 64` as `emulator-5554`.
- `adb devices` reported `emulator-5554 device`.
- `flutter doctor -v` reported no issues with Flutter 3.47.2, Android SDK 37,
  Java 17, licenses, or network resources.
- `flutter run -d emulator-5554` reached the Android Gradle
  `assembleDebug` step. The attached run was stopped while that build was
  still active, so a completed app launch was not claimed as automated
  verification.

## Remaining work

- Run `flutter run -d emulator-5554` again and wait for the first Gradle build
  to finish.
- Add widget/integration coverage for a valid URL, null URL, and failed image
  request.
- Consider a persistent image cache or bundled/generated fallback for offline
  use and Open Library failures.