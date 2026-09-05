import 'dart:math';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_session.dart';
import '../models/auth_session_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthSessionModel> login({required String email, required String password});
  Future<AuthSessionModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // Seeded so login can be tested without registering first.
  // password stored in plain text here ONLY because this is a throwaway
  // mock — a real datasource must never do this, obviously.
  final List<Map<String, dynamic>> _users = [
    {
      'userId': 'u1', 'fullName': 'Library Admin', 'email': 'admin@library.com',
      'phoneNumber': '+94711111111', 'password': 'admin123', 'role': UserRole.admin,
    },
    {
      'userId': 'u2', 'fullName': 'Amaya Perera', 'email': 'amaya@email.com',
      'phoneNumber': '+94712345678', 'password': 'member123', 'role': UserRole.member,
    },
  ];

  AuthSessionModel _sessionFor(Map<String, dynamic> user) {
    // TODO(phase-18): a real backend returns only { accessToken,
    // expiresInMinutes } — userId/role/fullName/email get derived by
    // decoding the JWT's claims client-side, not attached directly like
    // this. Faking a JWT here would just be busywork with no payoff
    // until there's a real token to decode.
    return AuthSessionModel(
      accessToken: 'mock-token-${Random().nextInt(999999)}',
      expiresInMinutes: 60,
      userId: user['userId'] as String,
      role: user['role'] as UserRole,
      fullName: user['fullName'] as String,
      email: user['email'] as String,
    );
  }

  @override
  Future<AuthSessionModel> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final match = _users.where(
      (u) => (u['email'] as String).toLowerCase() == email.toLowerCase() && u['password'] == password,
    );
    if (match.isEmpty) {
      throw const InvalidCredentialsException('Incorrect email or password.');
    }
    return _sessionFor(match.first);
  }

  @override
  Future<AuthSessionModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final exists = _users.any((u) => (u['email'] as String).toLowerCase() == email.toLowerCase());
    if (exists) {
      throw const EmailAlreadyExistsException('An account with this email already exists.');
    }
    final newUser = {
      'userId': 'u${_users.length + 1}',
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': UserRole.member, // always Member — see repository interface note
    };
    _users.add(newUser);
    return _sessionFor(newUser);
  }
}