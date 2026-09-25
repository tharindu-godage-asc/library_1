import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../error/exceptions.dart';

/// Thin wrapper around Library.Api.
class ApiClient {
  const ApiClient(this._httpClient);
  final http.Client _httpClient;

  Future<Map<String, dynamic>> keycloakWhoami({required String accessToken}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/keycloak-whoami');
    final response = await _httpClient.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode != 200) {
      throw UnexpectedException('keycloak-whoami returned ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Both resolve to the caller's own Member row server-side (via the
  // Keycloak-authenticated request's memberId, JIT-provisioning it on
  // first hit) — there's no client-known member id to put in the path.
  Future<Map<String, dynamic>> getMyProfile({required String accessToken}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/members/me');
    final response = await _httpClient.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    return _decodeMemberResponse(response);
  }

  Future<Map<String, dynamic>> updateMyProfile({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/members/me');
    final response = await _httpClient.put(
      uri,
      headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decodeMemberResponse(response);
  }

  Map<String, dynamic> _decodeMemberResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body) as Map<String, dynamic>;
      case 404:
        throw NotFoundException('Member not found.');
      case 409:
        throw const EmailAlreadyExistsException('An account with this email already exists.');
      default:
        throw UnexpectedException('Request failed (${response.statusCode}): ${response.body}');
    }
  }
}
