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
    this.idToken,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String userId;
  final UserRole role;
  final String fullName;
  final String email;
  // Hint Keycloak needs to actually end the browser SSO session on logout
  // (EndSessionRequest.idTokenHint) — without it, logout only clears local
  // tokens and the next login silently re-authenticates via the still-live
  // Keycloak session cookie. Nullable because a refresh response doesn't
  // always include a new one; callers fall back to the previous value.
  final String? idToken;

  bool get isAccessTokenExpired => DateTime.now().isAfter(accessTokenExpiresAt);
  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiresAt);
}