import '../../domain/entities/borrowing.dart';

/// Unlike BookModel, this stores DateTime/enum values directly rather
/// than ISO-8601 strings — deliberate shortcut, since this mock never
/// actually serializes to real JSON text. Real string<->DateTime and
/// string<->enum conversion is exactly what Phase 18 needs to add once
/// there's a real API response shape to match, not before.
class BorrowingModel {
  const BorrowingModel({
    required this.id, required this.bookId, required this.memberId,
    required this.borrowedDate, required this.dueDate,
    this.returnedDate, required this.status,
  });

  final String id;
  final String bookId;
  final String memberId;
  final DateTime borrowedDate;
  final DateTime dueDate;
  final DateTime? returnedDate;
  final BorrowingStatus status;

  factory BorrowingModel.fromJson(Map<String, dynamic> json) => BorrowingModel(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        memberId: json['memberId'] as String,
        borrowedDate: json['borrowedDate'] as DateTime,
        dueDate: json['dueDate'] as DateTime,
        returnedDate: json['returnedDate'] as DateTime?,
        status: json['status'] as BorrowingStatus,
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'bookId': bookId, 'memberId': memberId,
        'borrowedDate': borrowedDate, 'dueDate': dueDate,
        'returnedDate': returnedDate, 'status': status,
      };

  Borrowing toEntity() => Borrowing(
        id: id, bookId: bookId, memberId: memberId,
        borrowedDate: borrowedDate, dueDate: dueDate,
        returnedDate: returnedDate, status: status,
      );

  factory BorrowingModel.fromEntity(Borrowing b) => BorrowingModel(
        id: b.id, bookId: b.bookId, memberId: b.memberId,
        borrowedDate: b.borrowedDate, dueDate: b.dueDate,
        returnedDate: b.returnedDate, status: b.status,
      );
}