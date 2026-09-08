import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/borrowing.dart';
import '../../domain/repositories/borrowing_repository.dart';
import '../datasources/borrowing_local_datasource.dart';
import '../models/borrowing_model.dart';

class BorrowingRepositoryImpl implements BorrowingRepository {
  const BorrowingRepositoryImpl(this._dataSource);
  final BorrowingLocalDataSource _dataSource;

  @override
  Future<Either<Failure, Borrowing>> createBorrowing(Borrowing borrowing) async {
    try {
      final model = await _dataSource.create(BorrowingModel.fromEntity(borrowing));
      return Right(model.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Borrowing>> updateBorrowing(Borrowing borrowing) async {
    try {
      final model = await _dataSource.update(BorrowingModel.fromEntity(borrowing));
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Borrowing>>> getBorrowingsForMember(String memberId) async {
    try {
      final models = await _dataSource.fetchForMember(memberId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Borrowing>> getBorrowingById(String id) async {
    try {
      final model = await _dataSource.fetchById(id);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}