import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_appauth/flutter_appauth.dart';

import '../../../../core/auth/jwt_claims.dart';
import '../../../../core/config/keycloak_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_session.dart';
import '../models/auth_session_model.dart';

abstract class AuthKeycloakDataSource {
  Future<AuthSessionModel> login();
  Future<AuthSessionModel> register();
  Future<AuthSessionModel> refresh({required String refreshToken});

  /// Ends the Keycloak-side SSO session (the browser/custom-tab cookie),
  /// not just the locally-cached tokens — without this, a fresh login()
  /// silently re-authenticates through that still-live cookie instead of
  /// showing the credential form. Best-effort: callers shouldn't fail the
  /// whole logout over this.
  Future<void> endSession({required String idToken});
}

class AuthKeycloakDataSourceImpl implements AuthKeycloakDataSource {
  const AuthKeycloakDataSourceImpl(this._appAuth);
  final FlutterAppAuth _appAuth;

  // Keycloak's refresh_expires_in is a Keycloak-specific extension that may
  // not surface through tokenAdditionalParameters depending on how the
  // native AppAuth library parses it — fall back to this if it's absent.
  // Verify actual behavior at runtime; record it in the phase-13 doc.
  static const _fallbackRefreshTokenTtl = Duration(days: 30);

  @override
  Future<AuthSessionModel> login() async {
    final response = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        KeycloakConfig.clientId,
        KeycloakConfig.redirectUrl,
        issuer: KeycloakConfig.issuer,
        scopes: KeycloakConfig.scopes,
        // Local Keycloak runs on plain HTTP in this pass (emulator-only,
        // see KeycloakConfig) — AppAuth's Android library refuses non-HTTPS
        // endpoints unless told otherwise. Gated to debug builds so this
        // can't silently ship in a release build once KeycloakConfig.issuer
        // points at a real, HTTPS host.
        allowInsecureConnections: kDebugMode,
      ),
    );
    return _toSessionModel(response);
  }

  @override
  Future<AuthSessionModel> register() async {
    final response = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        KeycloakConfig.clientId,
        KeycloakConfig.redirectUrl,
        issuer: KeycloakConfig.issuer,
        scopes: KeycloakConfig.scopes,
        allowInsecureConnections: kDebugMode,
        // Keycloak 26's "Initiating User Registration" support — jumps
        // straight to the hosted sign-up form instead of the login form.
        // Must go through promptValues, not additionalParameters: AppAuth's
        // Android builder has a dedicated setter for "prompt" and throws if
        // it's also present in additionalParameters (IllegalArgumentException,
        // uncaught, crashes the app on register()).
        promptValues: const ['create'],
      ),
    );
    return _toSessionModel(response);
  }

  @override
  Future<void> endSession({required String idToken}) async {
    await _appAuth.endSession(
      EndSessionRequest(
        idTokenHint: idToken,
        // Without this, AppAuth's end-session request has nothing to
        // redirect back to once Keycloak finishes logging out — the browser
        // just sits on Keycloak's page and this Future never resolves. Reuse
        // the same custom-scheme redirect as login/register; Keycloak's
        // client config must list it under "Valid post logout redirect URIs"
        // (or have that set to "+") or Keycloak will refuse it.
        postLogoutRedirectUrl: KeycloakConfig.redirectUrl,
        issuer: KeycloakConfig.issuer,
        allowInsecureConnections: kDebugMode,
      ),
    );
  }

  @override
  Future<AuthSessionModel> refresh({required String refreshToken}) async {
    try {
      final response = await _appAuth.token(
        TokenRequest(
          KeycloakConfig.clientId,
          KeycloakConfig.redirectUrl,
          issuer: KeycloakConfig.issuer,
          scopes: KeycloakConfig.scopes,
          refreshToken: refreshToken,
          grantType: GrantType.refreshToken,
          allowInsecureConnections: kDebugMode,
        ),
      );
      return _toSessionModel(response);
    } on FlutterAppAuthPlatformException {
      throw const InvalidRefreshTokenException('Your session has expired. Please log in again.');
    }
  }

  AuthSessionModel _toSessionModel(TokenResponse response) {
    final accessToken = response.accessToken;
    final accessTokenExpiresAt = response.accessTokenExpirationDateTime;
    final refreshToken = response.refreshToken;
    if (accessToken == null || accessTokenExpiresAt == null || refreshToken == null) {
      throw const UnexpectedException('Keycloak did not return a complete token response.');
    }

    final claims = decodeJwtClaims(accessToken);
    final roles = (claims['realm_access'] as Map<String, dynamic>?)?['roles'] as List<dynamic>?;

    return AuthSessionModel(
      accessToken: accessToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshToken: refreshToken,
      refreshTokenExpiresAt: _refreshTokenExpiresAt(response),
      userId: claims['sub'] as String,
      role: (roles?.contains('Admin') ?? false) ? UserRole.admin : UserRole.member,
      fullName: claims['name'] as String? ?? '',
      email: claims['email'] as String? ?? '',
      idToken: response.idToken,
    );
  }

  DateTime _refreshTokenExpiresAt(TokenResponse response) {
    final raw = response.tokenAdditionalParameters?['refresh_expires_in'];
    final seconds = raw is String ? int.tryParse(raw) : (raw is int ? raw : null);
    if (seconds != null) {
      return DateTime.now().add(Duration(seconds: seconds));
    }
    return DateTime.now().add(_fallbackRefreshTokenTtl);
  }
}
