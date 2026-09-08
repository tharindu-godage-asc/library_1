import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../entities/borrowing.dart';
import '../repositories/borrowing_repository.dart';

class ReturnBorrowing {
  const ReturnBorrowing(this._bookRepository, this._borrowingRepository);
  final BookRepository _bookRepository;
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

    Book? book;
    (await _bookRepository.getBookById(borrowing!.bookId)).match((f) => earlyFailure = f, (b) => book = b);
    if (earlyFailure != null) return Left(earlyFailure!);

    (await _bookRepository.updateBook(book!.returnCopy())).match((f) => earlyFailure = f, (_) {});
    if (earlyFailure != null) return Left(earlyFailure!);

    final updated = borrowing!.copyWith(returnedDate: DateTime.now(), status: BorrowingStatus.returned);
    return _borrowingRepository.updateBorrowing(updated);
  }
}