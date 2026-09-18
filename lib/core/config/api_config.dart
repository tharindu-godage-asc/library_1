import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralizes Library.Api's connection details, read from .env (see
/// .env.example) — mirrors KeycloakConfig's approach.
class ApiConfig {
  const ApiConfig._();

  // 10.0.2.2 is the Android emulator's alias for the host machine, same as
  // KeycloakConfig.issuer. Plain HTTP, not the 7282 HTTPS port — Library.Api's
  // self-signed dev cert isn't trusted on the emulator (CERTIFICATE_VERIFY_FAILED),
  // and there's no way to make Dart's http.Client trust it without shipping a
  // cert bundle, so this goes through the same http://10.0.2.2:5281 endpoint
  // ASP.NET Core's "https" launch profile exposes alongside 7282. Requires
  // Library.Api's Development-only UseHttpsRedirection() skip (see Program.cs)
  // so it isn't just bounced back to the untrusted HTTPS port.
  static String get baseUrl => dotenv.env['API_BASE_URL']!;
}
