import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/books/presentation/screens/books_screen.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BooksnU',
      theme: AppTheme.light,
      home: const BooksScreen(),
    );
  }
}