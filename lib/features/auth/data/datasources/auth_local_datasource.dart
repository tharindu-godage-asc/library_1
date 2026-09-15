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
  Future<AuthSessionModel> refresh({required String refreshToken});
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _accessTokenTtl = Duration(minutes: 60);
  static const _refreshTokenTtl = Duration(days: 7);

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

  // refreshToken -> { userId, expiresAt }. Mirrors _users' loose Map style
  // rather than a dedicated model, since this is mock-only bookkeeping.
  final Map<String, Map<String, dynamic>> _refreshTokens = {};

  AuthSessionModel _issueSession(Map<String, dynamic> user) {
    // -TODO(phase-18): a real backend returns only { accessToken,
    // expiresInMinutes } — userId/role/fullName/email get derived by
    // decoding the JWT's claims client-side, not attached directly like
    // this. Faking a JWT here would just be busywork with no payoff
    // until there's a real token to decode.
    final now = DateTime.now();
    // Timestamp-prefixed so a Random() collision can't silently clobber
    // another user's still-active refresh token entry.
    final refreshToken = 'mock-refresh-${now.microsecondsSinceEpoch}-${Random().nextInt(999999)}';
    _refreshTokens[refreshToken] = {
      'userId': user['userId'] as String,
      'expiresAt': now.add(_refreshTokenTtl),
    };
    return AuthSessionModel(
      accessToken: 'mock-token-${Random().nextInt(999999)}',
      accessTokenExpiresAt: now.add(_accessTokenTtl),
      refreshToken: refreshToken,
      refreshTokenExpiresAt: now.add(_refreshTokenTtl),
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
    return _issueSession(match.first);
  }

  @override
  Future<AuthSessionModel> refresh({required String refreshToken}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final record = _refreshTokens[refreshToken];
    if (record == null || DateTime.now().isAfter(record['expiresAt'] as DateTime)) {
      throw const InvalidRefreshTokenException('Your session has expired. Please log in again.');
    }
    _refreshTokens.remove(refreshToken); // rotation: dead the instant it's redeemed
    final user = _users.firstWhere((u) => u['userId'] == record['userId']);
    return _issueSession(user);
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
    return _issueSession(newUser);
  }
}