import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.expiresInMinutes,
    required this.userId,
    required this.role,
    required this.fullName,
    required this.email,
  });

  final String accessToken;
  final int expiresInMinutes;
  final String userId;
  final UserRole role;
  final String fullName;
  final String email;

  AuthSession toEntity() => AuthSession(
        accessToken: accessToken,
        expiresInMinutes: expiresInMinutes,
        userId: userId,
        role: role,
        fullName: fullName,
        email: email,
      );
}