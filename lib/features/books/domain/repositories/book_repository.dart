import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/book.dart';

/// Domain declares what it needs; data layer decides how. This is the
/// contract that lets Phase 2's mock implementation be swapped for a real
/// API implementation later without this file — or anything above it —
/// changing at all.
abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, Book>> getBookById(String id);

  /// Persists a Book that already changed via its own domain method
  /// (borrowCopy()/returnCopy()) — the repository's job is storage, not
  /// deciding how the numbers should change.
  Future<Either<Failure, Unit>> updateBook(Book book);
}