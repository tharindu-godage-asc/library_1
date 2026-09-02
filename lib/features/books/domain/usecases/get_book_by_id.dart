import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBookById implements UseCase<Book, String> {
  const GetBookById(this._repository);
  final BookRepository _repository;

  @override
  Future<Either<Failure, Book>> call(String id) => _repository.getBookById(id);
}
