import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/borrowing.dart';
import '../repositories/borrowing_repository.dart';

class ReturnBorrowing {
  const ReturnBorrowing(this._borrowingRepository);
  final BorrowingRepository _borrowingRepository;

  Future<Either<Failure, Borrowing>> call(String borrowingId) async {
    Failure? earlyFailure;

    Borrowing? borrowing;
    (await _borrowingRepository.getBorrowingById(borrowingId))
        .match((f) => earlyFailure = f, (b) => borrowing = b);
    if (earlyFailure != null) return Left(earlyFailure!);

    // "A book cannot be returned twice."
    if (borrowing!.status == BorrowingStatus.returned) {
      return const Left(AlreadyReturnedFailure('This book has already been returned.'));
    }

    // The backend restores the book's available copy as part of the return.
    final updated = borrowing!.copyWith(returnedDate: DateTime.now(), status: BorrowingStatus.returned);
    return _borrowingRepository.updateBorrowing(updated);
  }
}
