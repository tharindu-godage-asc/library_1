# Flutter API Reference

A catalog of every distinct Flutter SDK widget/class and third-party package API actually used in `lib/`, grouped by category, with links to official docs.

## Core Flutter — Layout & Structure

| Item | Doc |
|---|---|
| `Scaffold` | https://api.flutter.dev/flutter/material/Scaffold-class.html |
| `Column` / `Row` | https://api.flutter.dev/flutter/widgets/Column-class.html · https://api.flutter.dev/flutter/widgets/Row-class.html |
| `Container` | https://api.flutter.dev/flutter/widgets/Container-class.html |
| `Stack` / `Positioned` | https://api.flutter.dev/flutter/widgets/Stack-class.html · https://api.flutter.dev/flutter/widgets/Positioned-class.html |
| `Padding` | https://api.flutter.dev/flutter/widgets/Padding-class.html |
| `SizedBox` | https://api.flutter.dev/flutter/widgets/SizedBox-class.html |
| `Align` / `Center` | https://api.flutter.dev/flutter/widgets/Align-class.html · https://api.flutter.dev/flutter/widgets/Center-class.html |
| `Expanded` | https://api.flutter.dev/flutter/widgets/Expanded-class.html |
| `SingleChildScrollView` | https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html |
| `ListView` / `ListView.separated` | https://api.flutter.dev/flutter/widgets/ListView-class.html |
| `SafeArea` | https://api.flutter.dev/flutter/widgets/SafeArea-class.html |
| `ClipRRect` | https://api.flutter.dev/flutter/widgets/ClipRRect-class.html |
| `PageView.builder` / `PageController` | https://api.flutter.dev/flutter/widgets/PageView-class.html · https://api.flutter.dev/flutter/widgets/PageController-class.html |

## Core Flutter — Input & Forms

| Item | Doc |
|---|---|
| `TextField` | https://api.flutter.dev/flutter/material/TextField-class.html |
| `TextEditingController` | https://api.flutter.dev/flutter/widgets/TextEditingController-class.html |
| `SearchBar` (Material 3) | https://api.flutter.dev/flutter/material/SearchBar-class.html |
| `InputDecoration` / `OutlineInputBorder` | https://api.flutter.dev/flutter/material/InputDecoration-class.html · https://api.flutter.dev/flutter/material/OutlineInputBorder-class.html |
| `ValueListenableBuilder` | https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html |
| `ElevatedButton` / `TextButton` / `IconButton` | https://api.flutter.dev/flutter/material/ElevatedButton-class.html · https://api.flutter.dev/flutter/material/TextButton-class.html · https://api.flutter.dev/flutter/material/IconButton-class.html |
| `GestureDetector` | https://api.flutter.dev/flutter/widgets/GestureDetector-class.html |
| `InkWell` / `Material` | https://api.flutter.dev/flutter/material/InkWell-class.html · https://api.flutter.dev/flutter/material/Material-class.html |

> The app validates forms manually via `setState` — no `Form`/`TextFormField`/`FormField` is used anywhere.

## Core Flutter — Navigation & Overlays

| Item | Doc |
|---|---|
| `Navigator` | https://api.flutter.dev/flutter/widgets/Navigator-class.html |
| `showDialog` / `Dialog` | https://api.flutter.dev/flutter/material/showDialog.html · https://api.flutter.dev/flutter/material/Dialog-class.html |
| `showModalBottomSheet` | https://api.flutter.dev/flutter/material/showModalBottomSheet.html |
| `ScaffoldMessenger` / `SnackBar` | https://api.flutter.dev/flutter/material/ScaffoldMessenger-class.html · https://api.flutter.dev/flutter/material/SnackBar-class.html |
| `AppBar` | https://api.flutter.dev/flutter/material/AppBar-class.html |
| `PopScope` | https://api.flutter.dev/flutter/widgets/PopScope-class.html |
| `NavigationBar` / `NavigationDestination` | https://api.flutter.dev/flutter/material/NavigationBar-class.html · https://api.flutter.dev/flutter/material/NavigationDestination-class.html |

## Core Flutter — Theming & Visual

| Item | Doc |
|---|---|
| `ThemeData` / `ColorScheme.fromSeed` | https://api.flutter.dev/flutter/material/ThemeData-class.html · https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html |
| `AppBarTheme` / `TextTheme` / `NavigationBarThemeData` / `SearchBarThemeData` / `CardThemeData` | https://api.flutter.dev/flutter/material/AppBarTheme-class.html · https://api.flutter.dev/flutter/material/TextTheme-class.html |
| `WidgetStateProperty` / `WidgetState` | https://api.flutter.dev/flutter/widgets/WidgetStateProperty-class.html |
| `BoxDecoration` / `LinearGradient` / `RadialGradient` | https://api.flutter.dev/flutter/painting/BoxDecoration-class.html · https://api.flutter.dev/flutter/painting/LinearGradient-class.html |
| `RoundedRectangleBorder` / `BorderRadius` | https://api.flutter.dev/flutter/painting/RoundedRectangleBorder-class.html · https://api.flutter.dev/flutter/painting/BorderRadius-class.html |
| `CircularProgressIndicator` | https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html |
| `Image.asset` / `Icon` | https://api.flutter.dev/flutter/widgets/Image/Image.asset.html · https://api.flutter.dev/flutter/widgets/Icon-class.html |
| `Card` / `CircleAvatar` | https://api.flutter.dev/flutter/material/Card-class.html · https://api.flutter.dev/flutter/material/CircleAvatar-class.html |
| `RichText` / `TextSpan` | https://api.flutter.dev/flutter/widgets/RichText-class.html · https://api.flutter.dev/flutter/painting/TextSpan-class.html |
| `Opacity` / `AnimatedContainer` | https://api.flutter.dev/flutter/widgets/Opacity-class.html · https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html |
| `MediaQuery` | https://api.flutter.dev/flutter/widgets/MediaQuery-class.html |

## Core Flutter — Async / Animation / Custom Painting

| Item | Doc |
|---|---|
| `Timer` (`dart:async`) | https://api.dart.dev/stable/dart-async/Timer-class.html |
| `Future` / `Future.wait` | https://api.dart.dev/stable/dart-async/Future-class.html |
| `StatefulWidget` / `State` / `StatelessWidget` | https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html · https://api.flutter.dev/flutter/widgets/State-class.html |
| `AnimationController` / `CurvedAnimation` / `AnimatedBuilder` / `Curves` | https://api.flutter.dev/flutter/animation/AnimationController-class.html · https://api.flutter.dev/flutter/animation/CurvedAnimation-class.html · https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html |
| `Transform` | https://api.flutter.dev/flutter/widgets/Transform-class.html |
| `CustomPaint` / `CustomPainter` | https://api.flutter.dev/flutter/widgets/CustomPaint-class.html · https://api.flutter.dev/flutter/rendering/CustomPainter-class.html |
| `ChangeNotifier` | https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html |
| `rootBundle` (`flutter/services.dart`) | https://api.flutter.dev/flutter/services/rootBundle.html |
| `json.decode` (`dart:convert`) | https://api.dart.dev/stable/dart-convert/JsonCodec-class.html |

## flutter_riverpod + riverpod_annotation

| Item | Doc |
|---|---|
| Package docs | https://riverpod.dev/docs/introduction/getting_started |
| `ProviderScope` | https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ProviderScope-class.html |
| `ConsumerWidget` / `ConsumerStatefulWidget` / `WidgetRef` | https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/ConsumerWidget-class.html · https://pub.dev/documentation/flutter_riverpod/latest/flutter_riverpod/WidgetRef-class.html |
| `ref.watch` / `.read` / `.listen` / `.invalidate` | https://riverpod.dev/docs/concepts/reading |
| `AsyncValue` (`.when`, `.asData`, `.isLoading`, `.hasError`) | https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html |
| `@riverpod` / `@Riverpod(keepAlive: true)` code generation | https://riverpod.dev/docs/concepts/about_code_generation |

## go_router

| Item | Doc |
|---|---|
| Package docs | https://pub.dev/documentation/go_router/latest/ |
| `GoRouter` | https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html |
| `GoRoute` | https://pub.dev/documentation/go_router/latest/go_router/GoRoute-class.html |
| `StatefulShellRoute.indexedStack` / `StatefulShellBranch` | https://pub.dev/documentation/go_router/latest/go_router/StatefulShellRoute-class.html |
| `StatefulNavigationShell` | https://pub.dev/documentation/go_router/latest/go_router/StatefulNavigationShell-class.html |
| `GoRouterState` | https://pub.dev/documentation/go_router/latest/go_router/GoRouterState-class.html |
| `context.go` / `context.push` / `context.pop` | https://pub.dev/documentation/go_router/latest/go_router/GoRouterHelper.html |

## Other packages

| Package | Used for | Doc |
|---|---|---|
| `flutter_secure_storage` | `FlutterSecureStorage().read/write/delete` (session storage) | https://pub.dev/packages/flutter_secure_storage |
| `shared_preferences` | `SharedPreferences.getInstance()`, `.getBool/.setBool` (onboarding flag) | https://pub.dev/packages/shared_preferences |
| `connectivity_plus` | `Connectivity()`, `.checkConnectivity()`, `.onConnectivityChanged` | https://pub.dev/packages/connectivity_plus |
| `fpdart` | `Either<Failure, T>` (`Left`/`Right`/`.match`), `Unit` — domain-layer error handling | https://pub.dev/packages/fpdart |
| `path_drawing` | `parseSvgPathData` — used in the splash screen's custom painters | https://pub.dev/packages/path_drawing |
| `cupertino_icons` | Declared in pubspec but **not referenced anywhere** in `lib/` — the app uses `Icons.*` exclusively | https://pub.dev/packages/cupertino_icons |

## Notably absent

`Form` / `TextFormField`, `FutureBuilder` / `StreamBuilder` (Riverpod's `AsyncValue.when` covers that instead), `Hero`, `TabBar` / `TabBarView` (the Borrowed/Returned tabs are a hand-built segmented control), and the plain (non-generated) Riverpod `Provider` / `StateNotifierProvider` APIs.
