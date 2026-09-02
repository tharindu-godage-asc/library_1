import '../entities/book.dart';

/// Domain declares what it needs; data layer decides how. This is the
/// contract that lets Phase 2's mock implementation be swapped for a real
/// API implementation later without this file — or anything above it —
/// changing at all.
abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<Book> getBookById(String id);
}