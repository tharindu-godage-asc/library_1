import '../../../../core/error/exceptions.dart';
import '../models/member_model.dart';

abstract class MemberLocalDataSource {
  Future<MemberModel> fetchById(String id);
  Future<MemberModel> update(MemberModel model);
}

class MemberLocalDataSourceImpl implements MemberLocalDataSource {
  MemberLocalDataSourceImpl() {
    final now = DateTime.now();
    // Same ids as AuthLocalDataSourceImpl's seeded users — deliberately
    // a separate store, not a shared object, matching the real-world
    // "identity service vs. profile service" split.
    _members.addAll([
      {
        'id': 'u1', 'fullName': 'Library Admin', 'email': 'admin@library.com',
        'phoneNumber': '+94711111111', 'registeredDate': now.subtract(const Duration(days: 400)),
        'isActive': true,
      },
      {
        'id': 'u2', 'fullName': 'Amaya Perera', 'email': 'amaya@email.com',
        'phoneNumber': '+94712345678', 'registeredDate': now.subtract(const Duration(days: 120)),
        'isActive': true,
      },
    ]);
  }

  final List<Map<String, dynamic>> _members = [];

  @override
  Future<MemberModel> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final match = _members.where((m) => m['id'] == id);
    if (match.isEmpty) throw NotFoundException('Member not found: $id');
    return MemberModel.fromJson(match.first);
  }

  @override
  Future<MemberModel> update(MemberModel model) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _members.indexWhere((m) => m['id'] == model.id);
    if (index == -1) throw NotFoundException('Member not found: ${model.id}');

    final emailTaken = _members.any(
      (m) => m['id'] != model.id && (m['email'] as String).toLowerCase() == model.email.toLowerCase(),
    );
    if (emailTaken) throw EmailAlreadyExistsException('An account with this email already exists.');

    _members[index] = model.toJson();
    return model;
  }
}