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

  /// One page of GET /api/books — the response is a paged envelope
  /// ({items, pageNumber, pageSize, totalCount, totalPages}).
  Future<Map<String, dynamic>> getBooksPage({
    required String accessToken,
    required int pageNumber,
    required int pageSize,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/books').replace(
      queryParameters: {'pageNumber': '$pageNumber', 'pageSize': '$pageSize'},
    );
    final response = await _httpClient.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    return _decodeResponse(response, notFoundMessage: 'Books not found.');
  }

  Future<Map<String, dynamic>> getBookById({required String accessToken, required String id}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/books/$id');
    final response = await _httpClient.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    return _decodeResponse(response, notFoundMessage: 'Book not found: $id');
  }

  /// GET /api/members/{memberId}/borrowings — a plain JSON array, and the
  /// route is OwnMember-protected, so memberId must be the caller's own
  /// backend Member id (not the Keycloak subject). There's no
  /// /borrowings/me, and GET /api/borrowings itself is AdminOnly.
  Future<List<dynamic>> getBorrowingsForMember({
    required String accessToken,
    required String memberId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/members/$memberId/borrowings');
    final response = await _httpClient.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode != 200) throw _problem(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getBorrowingById({required String accessToken, required String id}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/borrowings/$id');
    final response = await _httpClient.get(uri, headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode != 200) throw _problem(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createBorrowing({
    required String accessToken,
    required String bookId,
    required String memberId,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/borrowings');
    final response = await _httpClient.post(
      uri,
      headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
      body: jsonEncode({'bookId': bookId, 'memberId': memberId}),
    );
    if (response.statusCode != 201) throw _problem(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// POST /api/borrowings/{id}/return — 204 with no body on success.
  Future<void> returnBorrowing({required String accessToken, required String id}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/borrowings/$id/return');
    final response = await _httpClient.post(uri, headers: {'Authorization': 'Bearer $accessToken'});
    if (response.statusCode != 204) throw _problem(response);
  }

  /// Turns a non-success response into an exception. Library.Api's domain
  /// errors come back as ProblemDetails with a `code` extension; anything
  /// else (401/403 from auth, proxies, crashes) has no such body.
  Exception _problem(http.Response response) {
    if (response.statusCode == 404) return NotFoundException('Not found.');
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return ApiProblemException(
          statusCode: response.statusCode,
          code: body['code'] as String?,
          message: (body['detail'] ?? body['title'] ?? 'Request failed (${response.statusCode}).') as String,
        );
      }
    } catch (_) {}
    return UnexpectedException('Request failed (${response.statusCode}): ${response.body}');
  }

  Map<String, dynamic> _decodeResponse(http.Response response, {required String notFoundMessage}) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body) as Map<String, dynamic>;
      case 404:
        throw NotFoundException(notFoundMessage);
      default:
        throw UnexpectedException('Request failed (${response.statusCode}): ${response.body}');
    }
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
