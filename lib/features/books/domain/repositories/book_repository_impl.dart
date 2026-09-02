import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../data/datasources/book_mock_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  const BookRepositoryImpl(this._dataSource);
  final BookMockDataSource _dataSource;

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      final models = await _dataSource.fetchBooks();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> getBookById(String id) async {
    try {
      final model = await _dataSource.fetchBookById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }
}
