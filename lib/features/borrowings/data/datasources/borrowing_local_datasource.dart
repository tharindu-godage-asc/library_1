import '../../../../core/error/exceptions.dart';
import '../../domain/entities/borrowing.dart';
import '../models/borrowing_model.dart';

abstract class BorrowingLocalDataSource {
  Future<BorrowingModel> create(BorrowingModel model);
  Future<BorrowingModel> update(BorrowingModel model);
  Future<List<BorrowingModel>> fetchForMember(String memberId);
  Future<BorrowingModel> fetchById(String id);
}

class BorrowingLocalDataSourceImpl implements BorrowingLocalDataSource {
  BorrowingLocalDataSourceImpl() {
    final now = DateTime.now();

    _borrowings.addAll([
      {
        // Clean Code, due soon — surfaces the Books home screen's reminder banner
        'id': 'br1', 'bookId': '1', 'memberId': 'u2',
        'borrowedDate': now.subtract(const Duration(days: 12)),
        'dueDate': now.add(const Duration(days: 2)),
        'returnedDate': null, 'status': BorrowingStatus.borrowed,
      },
      {
        // Domain-Driven Design, dueDate already in the past — recomputed to Overdue at fetch time
        'id': 'br2', 'bookId': '5', 'memberId': 'u2',
        'borrowedDate': now.subtract(const Duration(days: 16)),
        'dueDate': now.subtract(const Duration(days: 2)),
        'returnedDate': null, 'status': BorrowingStatus.borrowed,
      },
      {
        // Design Patterns, already returned
        'id': 'br3', 'bookId': '3', 'memberId': 'u2',
        'borrowedDate': now.subtract(const Duration(days: 30)),
        'dueDate': now.subtract(const Duration(days: 16)),
        'returnedDate': now.subtract(const Duration(days: 20)),
        'status': BorrowingStatus.returned,
      },
    ]);
  }

  final List<Map<String, dynamic>> _borrowings = [];
  int _nextId = 4;

  BorrowingModel _withEffectiveStatus(BorrowingModel m) {
    if (m.status == BorrowingStatus.returned) return m;
    final isOverdue = DateTime.now().isAfter(m.dueDate);
    if (!isOverdue) return m;
    return BorrowingModel(
      id: m.id, bookId: m.bookId, memberId: m.memberId,
      borrowedDate: m.borrowedDate, dueDate: m.dueDate,
      returnedDate: m.returnedDate, status: BorrowingStatus.overdue,
    );
  }

  @override
  Future<BorrowingModel> create(BorrowingModel model) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final stored = BorrowingModel(
      id: 'br${_nextId++}', bookId: model.bookId, memberId: model.memberId,
      borrowedDate: model.borrowedDate, dueDate: model.dueDate,
      returnedDate: model.returnedDate, status: model.status,
    );
    _borrowings.add(stored.toJson());
    return stored;
  }

  @override
  Future<BorrowingModel> update(BorrowingModel model) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _borrowings.indexWhere((b) => b['id'] == model.id);
    if (index == -1) throw NotFoundException('Borrowing not found: ${model.id}');
    _borrowings[index] = model.toJson();
    return model;
  }

  @override
  Future<List<BorrowingModel>> fetchForMember(String memberId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _borrowings
        .where((b) => b['memberId'] == memberId)
        .map((b) => _withEffectiveStatus(BorrowingModel.fromJson(b)))
        .toList();
  }

  @override
  Future<BorrowingModel> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final match = _borrowings.where((b) => b['id'] == id);
    if (match.isEmpty) throw NotFoundException('Borrowing not found: $id');
    return _withEffectiveStatus(BorrowingModel.fromJson(match.first));
  }
}