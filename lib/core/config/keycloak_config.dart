import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralizes the Keycloak connection details, read from .env (see
/// .env.example) so the emulator-specific host isn't baked into the binary
/// and can be swapped per developer/environment without a code change.
class KeycloakConfig {
  const KeycloakConfig._();

  static String get issuer => dotenv.env['KEYCLOAK_ISSUER']!;
  static String get clientId => dotenv.env['KEYCLOAK_CLIENT_ID']!;
  // Underscore-free by necessity, not convention — it doesn't need to match
  // the Android applicationId (com.example.library_1); URI scheme syntax
  // (RFC 3986) disallows underscores, so "library_1" can't be reused as-is.
  static String get redirectUrl => dotenv.env['KEYCLOAK_REDIRECT_URL']!;
  static const scopes = ['openid', 'profile', 'email'];
}
