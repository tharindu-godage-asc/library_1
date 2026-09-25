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
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, Borrowing>> updateBorrowing(Borrowing borrowing) async {
    try {
      final model = await _dataSource.update(BorrowingModel.fromEntity(borrowing));
      return Right(model.toEntity());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Borrowing>>> getBorrowingsForMember(String memberId) async {
    try {
      final models = await _dataSource.fetchForMember(memberId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, Borrowing>> getBorrowingById(String id) async {
    try {
      final model = await _dataSource.fetchById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  /// Maps Library.Api's domain error codes onto the app's specific failures
  /// so the UI can show a precise message; anything unrecognized stays a
  /// generic failure.
  Failure _toFailure(Object e) {
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ApiProblemException) {
      switch (e.code) {
        case 'Book.NoAvailableCopies':
          return BookUnavailableFailure(e.message);
        case 'Borrowing.LimitExceeded':
          return BorrowingLimitExceededFailure(e.message);
        case 'Borrowing.AlreadyReturned':
          return AlreadyReturnedFailure(e.message);
        case 'Member.Inactive':
          return MemberInactiveFailure(e.message);
        case 'Book.NotFound':
        case 'Borrowing.NotFound':
        case 'Member.NotFound':
          return NotFoundFailure(e.message);
      }
    }
    return UnexpectedFailure(e.toString());
  }
}
