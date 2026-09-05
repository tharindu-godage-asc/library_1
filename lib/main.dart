import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/books/presentation/screens/books_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: LibraryApp()));
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BooksnU',
      theme: AppTheme.light,
      home: const LoginScreen(),
      // home: const SplashScreen(),
    );
  }
}