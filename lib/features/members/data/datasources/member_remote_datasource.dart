import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/member_model.dart';
import 'member_local_datasource.dart';

typedef AccessTokenProvider = Future<String?> Function();

/// Backs the [MemberLocalDataSource] contract with Library.Api instead of
/// the in-memory mock. Both `/api/members/me` calls resolve to the caller's
/// own Member row server-side (JIT-provisioning it on first hit) — Keycloak
/// tokens carry no client-known member id, so [id] is accepted only to
/// satisfy the shared interface and is otherwise ignored.
class MemberRemoteDataSourceImpl implements MemberLocalDataSource {
  const MemberRemoteDataSourceImpl(this._apiClient, this._accessTokenProvider);
  final ApiClient _apiClient;
  final AccessTokenProvider _accessTokenProvider;

  @override
  Future<MemberModel> fetchById(String id) async {
    final token = await _requireAccessToken();
    final json = await _apiClient.getMyProfile(accessToken: token);
    return _fromApiJson(json);
  }

  @override
  Future<MemberModel> update(MemberModel model) async {
    final token = await _requireAccessToken();
    final json = await _apiClient.updateMyProfile(
      accessToken: token,
      body: {
        'name': model.fullName,
        'email': model.email,
        'phoneNumber': model.phoneNumber,
      },
    );
    return _fromApiJson(json);
  }

  Future<String> _requireAccessToken() async {
    final token = await _accessTokenProvider();
    if (token == null) throw const UnexpectedException('No active session.');
    return token;
  }

  // Library.Api's MemberResponse shape is {id, name, email, phoneNumber,
  // isActive} — different field names than MemberModel.fromJson expects
  // (fullName/registeredDate), and it has no registeredDate at all (not
  // implemented server-side yet). Nothing in the UI reads registeredDate,
  // so DateTime.now() here is a harmless placeholder, not real data.
  MemberModel _fromApiJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'] as String,
        fullName: json['name'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        registeredDate: DateTime.now(),
        isActive: json['isActive'] as bool,
      );
}
