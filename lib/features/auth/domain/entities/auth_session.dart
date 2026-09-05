enum UserRole { admin, member }

/// What "being logged in" means to the rest of the app. Deliberately NOT
/// the same as a future Members-feature `Member` entity — Auth doesn't
/// depend on Members, and the login response doesn't return a full
/// profile anyway (per the API reference, just a token + expiry).
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