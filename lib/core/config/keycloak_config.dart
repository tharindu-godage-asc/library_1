/// Centralizes the Keycloak connection details so the emulator-specific
/// host lives in one place, ready to swap for a device/LAN IP later.
class KeycloakConfig {
  const KeycloakConfig._();

  static const issuer = 'http://10.0.2.2:8081/realms/library';
  static const clientId = 'library-flutter';
  static const redirectUrl = 'com.example.library_1:/oauthredirect';
  static const scopes = ['openid', 'profile', 'email'];
}
