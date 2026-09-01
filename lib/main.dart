import 'package:flutter/material.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Library Management',
      home: Scaffold(
        body: Center(child: Text('Coming soon')),
      ),
    );
  }
}
