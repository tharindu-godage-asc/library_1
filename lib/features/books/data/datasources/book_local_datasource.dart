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
/// HTTP client. Data is built via fromJson from the decoded JSON, not a
/// convenient Dart object, so swapping this for a real ApiBookDataSource
/// later is an implementation swap, not a rewrite.
///
/// The decoded rows are cached in [_books] after the first load rather
/// than re-read from the asset on every call: once updateBook() can
/// mutate availableCopies, re-reading the asset would silently discard
/// every borrow/return by reloading the pristine seed data. This is also
/// why bookLocalDataSourceProvider is `keepAlive` — a fresh instance
/// would lose this cache and reset every book back to its seeded state.
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