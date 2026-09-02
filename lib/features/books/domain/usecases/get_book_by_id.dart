import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBookById {
  const GetBookById(this._repository);
  final BookRepository _repository;

  Future<Book> call(String id) => _repository.getBookById(id);
}