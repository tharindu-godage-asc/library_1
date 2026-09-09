import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../entities/borrowing.dart';
import '../repositories/borrowing_repository.dart';

class BorrowBook {
  const BorrowBook(this._bookRepository, this._borrowingRepository, this._memberRepository);
  final BookRepository _bookRepository;
  final BorrowingRepository _borrowingRepository;
  final MemberRepository _memberRepository;

  Future<Either<Failure, Borrowing>> call({
    required String bookId,
    required String memberId,
  }) async {
    Failure? earlyFailure;

    Member? member;
    (await _memberRepository.getMemberById(memberId)).match((f) => earlyFailure = f, (m) => member = m);
    if (earlyFailure != null) return Left(earlyFailure!);
    if (!member!.isActive) {
      return const Left(MemberInactiveFailure('Your account is inactive and cannot borrow books.'));
    }

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