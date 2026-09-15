import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Center(
      child: Text('Something went wrong displaying this.'),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Add Sentry here
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught platform error: $error\n$stack');
    return true; // handled
  };

  runZonedGuarded(
    () => runApp(const ProviderScope(child: LibraryApp())),
    (Object error, StackTrace stack) {
      // Add Sentry
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

class LibraryApp extends ConsumerWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BooksnU',
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
