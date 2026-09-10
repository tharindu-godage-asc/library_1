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

/*
 * Borrowing Data Flow & Lifecycle:
 * 
 * 1. Incoming Data (Read / Fetch / GET)
 *    - JSON -> Model: BorrowingModel.fromJson(json) parses raw network/database data (with safe type handling for dates and status enums) into a model.
 *    - Model -> Entity: model.toEntity() converts that model into a pure Borrowing entity so your domain layer and UI can use it cleanly.
 * 
 * 2. Outgoing Data (Write / Update / POST / PUT)
 *    - Entity -> Model: BorrowingModel.fromEntity(borrowing) takes your pure domain entity from the UI/Use Case and wraps it into a BorrowingModel.
 *    - Model -> JSON: model.toJson() serializes that model into a key-value map (converting DateTimes to ISO8601 strings and status enums to strings) to be sent to your API.
 */