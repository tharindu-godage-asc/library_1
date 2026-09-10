enum UserRole { admin, member }

class AuthSession {
  const AuthSession({
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
}