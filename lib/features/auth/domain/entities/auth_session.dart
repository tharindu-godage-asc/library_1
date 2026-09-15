enum UserRole { admin, member }

class AuthSession {
  const AuthSession({
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

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiresAt);
  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiresAt);
}