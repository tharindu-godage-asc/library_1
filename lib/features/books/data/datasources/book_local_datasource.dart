import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class BookLocalDataSource {
  Future<List<BookModel>> fetchBooks();
  Future<BookModel> fetchBookById(String id);
  Future<BookModel> updateBook(BookModel model);
}

/// Reads from the bundled assets/data/books.json — stands in for a real

class BookLocalDataSourceImpl implements BookLocalDataSource {
  List<Map<String, dynamic>>? _books;

  Future<List<Map<String, dynamic>>> _ensureLoaded() async {
    final cached = _books;
    if (cached != null) return cached;
    final data = await rootBundle.loadString('assets/data/books.json');
    final decoded = (json.decode(data) as List).cast<Map<String, dynamic>>();
    return _books = decoded;
  }

  @override
  Future<List<BookModel>> fetchBooks() async {
    final books = await _ensureLoaded();
    return books.map(BookModel.fromJson).toList();
  }

  @override
  Future<BookModel> fetchBookById(String id) async {
    final books = await _ensureLoaded();
    final match = books.where((b) => b['id'].toString() == id);
    if (match.isEmpty) {
      throw NotFoundException('Book not found: $id');
    }
    return BookModel.fromJson(match.first);
  }

  @override
  Future<BookModel> updateBook(BookModel model) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final books = await _ensureLoaded();
    final index = books.indexWhere((b) => b['id'].toString() == model.id);
    if (index == -1) throw NotFoundException('Book not found: ${model.id}');
    books[index] = model.toJson();
    return model;
  }
}