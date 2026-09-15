import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.userId,
    required this.role,
    required this.fullName,
    required this.email,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String userId;
  final UserRole role;
  final String fullName;
  final String email;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) => AuthSessionModel(
        accessToken: json['accessToken'] as String,
        accessTokenExpiresAt: DateTime.parse(json['accessTokenExpiresAt'] as String),
        refreshToken: json['refreshToken'] as String,
        refreshTokenExpiresAt: DateTime.parse(json['refreshTokenExpiresAt'] as String),
        userId: json['userId'] as String,
        role: _parseRole(json['role']),
        fullName: json['fullName'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'accessTokenExpiresAt': accessTokenExpiresAt.toIso8601String(),
        'refreshToken': refreshToken,
        'refreshTokenExpiresAt': refreshTokenExpiresAt.toIso8601String(),
        'userId': userId,
        'role': role.name,
        'fullName': fullName,
        'email': email,
      };

  static UserRole _parseRole(Object? value) {
    if (value is UserRole) return value;
    return UserRole.values.byName(value as String);
  }

  AuthSession toEntity() => AuthSession(
        accessToken: accessToken,
        accessTokenExpiresAt: accessTokenExpiresAt,
        refreshToken: refreshToken,
        refreshTokenExpiresAt: refreshTokenExpiresAt,
        userId: userId,
        role: role,
        fullName: fullName,
        email: email,
      );
}
