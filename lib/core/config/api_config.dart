/// Centralizes Library.Api's connection details for the manual
/// keycloak-whoami smoke test, mirroring KeycloakConfig's approach.
class ApiConfig {
  const ApiConfig._();

  // 10.0.2.2 is the Android emulator's alias for the host machine, same
  // as KeycloakConfig.issuer. Library.Api's ASP.NET Core dev cert may not
  // be trusted on the emulator — if the smoke test fails with a TLS
  // handshake error, that's the first thing to check.
  static const baseUrl = 'https://10.0.2.2:7282/api';
}
