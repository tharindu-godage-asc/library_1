import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_local_datasource.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  const BookRepositoryImpl(this._dataSource);
  final BookLocalDataSource _dataSource;

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
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

@override
  Future<Either<Failure, Unit>> updateBook(Book book) async {
    try {
      await _dataSource.updateBook(BookModel.fromEntity(book));
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
