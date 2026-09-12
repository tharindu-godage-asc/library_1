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

/*
 * BookRepositoryImpl:
 * 
 * Acts as the concrete implementation of the BookRepository interface. 
 * It coordinates data operations by talking to the BookLocalDataSource 
 * and translating data models to domain entities (and vice versa) 
 * while wrapping results in an fpdart Either<Failure, T> type for 
 * robust, functional error handling.
 * 
 * - Read Operations (getBooks, getBookById): 
 *   Fetches BookModels -> converts them via toEntity() -> returns Right(Entity).
 * - Write Operations (updateBook): 
 *   Takes a domain Entity -> converts it via BookModel.fromEntity() -> passes to data source.
 */