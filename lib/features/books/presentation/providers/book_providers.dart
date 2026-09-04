import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/book_mock_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/get_book_by_id.dart';
import '../../domain/usecases/get_books.dart';

// ---- Composition root for the Books feature ----------------------------
// This is the Dependency Injection phase's actual job, showing up early
// because Riverpod's provider graph does it as a side effect: each layer
// is wired to the one below it exactly once, here — not re-constructed
// inside every screen the way Phase 2 did it.

final bookMockDataSourceProvider = Provider<BookMockDataSource>((ref) {
  return BookMockDataSource();
});

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl(ref.watch(bookMockDataSourceProvider));
});

final getBooksProvider = Provider<GetBooks>((ref) {
  return GetBooks(ref.watch(bookRepositoryProvider));
});

final getBookByIdProvider = Provider<GetBookById>((ref) {
  return GetBookById(ref.watch(bookRepositoryProvider));
});

// ---- App state the screens actually consume -----------------------------

/// Fetches once, caches the result across every widget that watches it.
/// `ref.invalidate(booksProvider)` re-runs it — that's what "Retry" now
/// calls, and what a future pull-to-refresh would call too.
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final getBooks = ref.watch(getBooksProvider);
  return getBooks();
});

/// `.family` because it's parameterized by id — Riverpod caches each
/// (provider, id) pair independently, so book "b1" and book "b2" don't
/// share or overwrite each other's loading/data/error state.
final bookByIdProvider = FutureProvider.family<Book, String>((ref, id) async {
  final getBookById = ref.watch(getBookByIdProvider);
  return getBookById(id);
});