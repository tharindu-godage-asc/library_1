import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/repositories/book_repository.dart';
import '../../../members/domain/entities/member.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../entities/borrowing.dart';
import '../repositories/borrowing_repository.dart';
import 'dart:async';

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

    // The three reads below don't depend on each other's results (only on
    // the memberId/bookId params already in hand), so they're fetched
    // concurrently here instead of one-await-at-a-time. What must NOT
    // change is failure precedence: if multiple things are wrong at once,
    // the checks below still run in the same order (member, then book,
    // then borrowing limit) so the same failure wins as before.
    final (memberResult, bookResult, borrowingsResult) = await (
      _memberRepository.getMemberById(memberId),
      _bookRepository.getBookById(bookId),
      _borrowingRepository.getBorrowingsForMember(memberId),
    ).wait;

    Member? member;
    memberResult.match((f) => earlyFailure = f, (m) => member = m);
    if (earlyFailure != null) return Left(earlyFailure!);
    if (!member!.isActive) {
      return const Left(MemberInactiveFailure('Your account is inactive and cannot borrow books.'));
    }

    Book? book;
    bookResult.match((f) => earlyFailure = f, (b) => book = b);
    if (earlyFailure != null) return Left(earlyFailure!);
    if (!book!.isAvailable) {
      return Left(BookUnavailableFailure('${book!.title} has no available copies right now.'));
    }

    List<Borrowing>? existing;
    borrowingsResult.match((f) => earlyFailure = f, (list) => existing = list);
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