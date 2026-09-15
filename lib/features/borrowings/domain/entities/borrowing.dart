enum BorrowingStatus { borrowed, returned, overdue }

class Borrowing {
  const Borrowing({
    required this.id,
    required this.bookId,
    required this.memberId,
    required this.borrowedDate,
    required this.dueDate,
    this.returnedDate,
    required this.status,
  });

  final String id;
  final String bookId;
  final String memberId;
  final DateTime borrowedDate;
  final DateTime dueDate;
  final DateTime? returnedDate;
  final BorrowingStatus status;

  Borrowing copyWith({DateTime? returnedDate, BorrowingStatus? status}) {
    return Borrowing(
      id: id, bookId: bookId, memberId: memberId,
      borrowedDate: borrowedDate, dueDate: dueDate,
      returnedDate: returnedDate ?? this.returnedDate,
      status: status ?? this.status,
    );
  }
}