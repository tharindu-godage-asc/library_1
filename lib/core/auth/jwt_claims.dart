import 'dart:convert';

/// Decodes a JWT's payload segment without verifying its signature —
/// the API is the trust boundary, not the app.
Map<String, dynamic> decodeJwtClaims(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw const FormatException('Invalid JWT: expected 3 dot-separated parts');
  }
  final payload = base64Url.normalize(parts[1]);
  return jsonDecode(utf8.decode(base64Url.decode(payload))) as Map<String, dynamic>;
}
