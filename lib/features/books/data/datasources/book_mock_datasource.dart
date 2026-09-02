import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/book_model.dart';

/// Stands in for a real HTTP client. Data is built via fromJson from
/// Map literals — deliberately, so it's already shaped like it's coming
/// off the wire, not constructed as a convenient Dart object. That's
/// what makes swapping this for a real ApiBookDataSource in Phase 18
/// an implementation swap, not a rewrite.
class BookMockDataSource {
 
  Future<List<BookModel>> fetchBooks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final books = await rootBundle.loadString('assets/mock_data/books.json');
    final booksList = json.decode(books) as List;
    return booksList.map((b) => BookModel.fromJson(b)).toList();
  }

  Future<BookModel> fetchBookById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final books = await rootBundle.loadString('assets/mock_data/books.json');
    final booksList = json.decode(books) as List;
    final match = booksList.where((b) => b['id'] == id);
    if (match.isEmpty) {
      throw Exception('Book not found: $id');
    }
    return BookModel.fromJson(match.first);
  }
}