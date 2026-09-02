import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBooks {
  const GetBooks(this._repository);
  final BookRepository _repository;

  Future<List<Book>> call() => _repository.getBooks();
}