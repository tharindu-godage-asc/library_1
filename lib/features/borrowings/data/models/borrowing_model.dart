import '../../domain/entities/borrowing.dart';

class BorrowingModel extends Borrowing {
  const BorrowingModel({
    required super.id, 
    required super.bookId, 
    required super.memberId,
    required super.borrowedDate, 
    required super.dueDate,
    super.returnedDate, 
    required super.status,
  });

  factory BorrowingModel.fromJson(Map<String, dynamic> json) => BorrowingModel(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        memberId: json['memberId'] as String,
        borrowedDate: _parseDateTime(json['borrowedDate']),
        dueDate: _parseDateTime(json['dueDate']),
        returnedDate: _parseNullableDateTime(json['returnedDate']),
        status: _parseStatus(json['status']),
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'bookId': bookId, 'memberId': memberId,
        'borrowedDate': borrowedDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'returnedDate': returnedDate?.toIso8601String(),
        'status': status.name,
      };

  static DateTime _parseDateTime(Object? value) {
    if (value is DateTime) return value;
    return DateTime.parse(value as String);
  }

  static DateTime? _parseNullableDateTime(Object? value) {
    if (value == null) return null;
    return _parseDateTime(value);
  }

  static BorrowingStatus _parseStatus(Object? value) {
    if (value is BorrowingStatus) return value;
    return BorrowingStatus.values.byName(value as String);
  }

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