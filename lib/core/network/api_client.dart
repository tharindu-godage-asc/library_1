import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../error/exceptions.dart';

/// Thin wrapper around Library.Api, currently used for one thing only:
/// the manual keycloak-whoami smoke test (see docs/phase-13). Not wired
/// into login/register — deliberately out of scope per that feature's spec.
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
}
