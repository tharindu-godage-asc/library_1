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

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) => AuthSessionModel(
        accessToken: json['accessToken'] as String,
        expiresInMinutes: json['expiresInMinutes'] as int,
        userId: json['userId'] as String,
        role: _parseRole(json['role']),
        fullName: json['fullName'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'expiresInMinutes': expiresInMinutes,
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
        expiresInMinutes: expiresInMinutes,
        userId: userId,
        role: role,
        fullName: fullName,
        email: email,
      );
}