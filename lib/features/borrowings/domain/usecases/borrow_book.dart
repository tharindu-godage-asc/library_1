import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../entities/borrowing.dart';
import '../repositories/borrowing_repository.dart';

/// Depends on BOTH repositories deliberately — this is what a use case is
/// for. BookRepository stays focused on persisting Books; BorrowingRepository
/// stays focused on persisting Borrowings; this class is the one place
/// allowed to know that "borrowing a book" touches both.
///
/// Note on style: each step below unwraps its Either with `.match()` into
/// a mutable local rather than chaining functionally (fpdart's TaskEither
/// would remove the repetition here) — deliberately not introducing a
/// second functional-programming concept mid-feature. Worth revisiting in
/// the Refactoring phase once there are more use cases like this one.
class BorrowBook {
  const BorrowBook(this._bookRepository, this._borrowingRepository);
  final BookRepository _bookRepository;
  final BorrowingRepository _borrowingRepository;

  Future<Either<Failure, Borrowing>> call({
    required String bookId,
    required String memberId,
  }) async {
    // TODO(members): also enforce "member must be active" here once the
    // Members feature exists — AuthSession has no isActive field yet, so
    // this rule from the API reference is intentionally NOT enforced
    // rather than faked.

    Failure? earlyFailure;

    Book? book;
    (await _bookRepository.getBookById(bookId)).match((f) => earlyFailure = f, (b) => book = b);
    if (earlyFailure != null) return Left(earlyFailure!);

    if (!book!.isAvailable) {
      return Left(BookUnavailableFailure('${book!.title} has no available copies right now.'));
    }

    List<Borrowing>? existing;
    (await _borrowingRepository.getBorrowingsForMember(memberId))
        .match((f) => earlyFailure = f, (list) => existing = list);
    if (earlyFailure != null) return Left(earlyFailure!);

    final activeCount = existing!.where((b) => b.status != BorrowingStatus.returned).length;
    if (activeCount >= 3) {
      return const Left(BorrowingLimitExceededFailure('You already have 3 active borrowings.'));
    }

    (await _bookRepository.updateBook(book!.borrowCopy())).match((f) => earlyFailure = f, (_) {});
    if (earlyFailure != null) return Left(earlyFailure!);

    final now = DateTime.now();
    final newBorrowing = Borrowing(
      id: '', // assigned by the data source on create
      bookId: bookId,
      memberId: memberId,
      borrowedDate: now,
      dueDate: now.add(const Duration(days: 14)),
      returnedDate: null,
      status: BorrowingStatus.borrowed,
    );

    return _borrowingRepository.createBorrowing(newBorrowing);
  }
}