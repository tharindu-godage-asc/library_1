import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class BookLocalDataSource {
  Future<List<BookModel>> fetchBooks();
  Future<BookModel> fetchBookById(String id);
}

/// Reads from the bundled assets/data/books.json — stands in for a real
/// HTTP client. Data is built via fromJson from the decoded JSON, not a
/// convenient Dart object, so swapping this for a real ApiBookDataSource
/// later is an implementation swap, not a rewrite.
class BookLocalDataSourceImpl implements BookLocalDataSource {
  Future<List<dynamic>> _loadBooks() async {
    final data = await rootBundle.loadString('assets/data/books.json');
    return json.decode(data) as List;
  }

  @override
  Future<List<BookModel>> fetchBooks() async {
    final books = await _loadBooks();
    return books.map((b) => BookModel.fromJson(b as Map<String, dynamic>)).toList();
  }

  @override
  Future<BookModel> fetchBookById(String id) async {
    final books = await _loadBooks();
    final match = books.where((b) => b['id'].toString() == id);
    if (match.isEmpty) {
      throw NotFoundException('Book not found: $id');
    }
    return BookModel.fromJson(match.first as Map<String, dynamic>);
  }
}