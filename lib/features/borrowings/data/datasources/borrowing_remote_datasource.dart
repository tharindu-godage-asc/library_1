import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/borrowing_model.dart';
import 'borrowing_local_datasource.dart';

typedef AccessTokenProvider = Future<String?> Function();

/// Backs the [BorrowingLocalDataSource] contract with Library.Api instead of
/// the in-memory mock.
///
/// The memberId arguments the app passes around are the Keycloak subject,
/// which Library.Api doesn't know as a Member id — so, like
/// MemberRemoteDataSourceImpl, they're ignored and the caller's real Member
/// id is resolved server-side via /members/me.
///
/// The backend owns the due date, the available-copies change and the rule
/// checks; [create] only says which book to borrow.
class BorrowingRemoteDataSourceImpl implements BorrowingLocalDataSource {
  const BorrowingRemoteDataSourceImpl(this._apiClient, this._accessTokenProvider);
  final ApiClient _apiClient;
  final AccessTokenProvider _accessTokenProvider;

  @override
  Future<List<BorrowingModel>> fetchForMember(String memberId) async {
    final token = await _requireAccessToken();
    final json = await _apiClient.getBorrowingsForMember(
      accessToken: token,
      memberId: await _ownMemberId(token),
    );
    return json.cast<Map<String, dynamic>>().map(BorrowingModel.fromApiJson).toList();
  }

  @override
  Future<BorrowingModel> fetchById(String id) async {
    final token = await _requireAccessToken();
    return BorrowingModel.fromApiJson(await _apiClient.getBorrowingById(accessToken: token, id: id));
  }

  @override
  Future<BorrowingModel> create(BorrowingModel model) async {
    final token = await _requireAccessToken();
    final json = await _apiClient.createBorrowing(
      accessToken: token,
      bookId: model.bookId,
      memberId: await _ownMemberId(token),
    );
    return BorrowingModel.fromApiJson(json);
  }

  /// The only update the backend supports is returning a borrowing — its
  /// endpoint answers 204, so the updated record is refetched.
  @override
  Future<BorrowingModel> update(BorrowingModel model) async {
    final token = await _requireAccessToken();
    await _apiClient.returnBorrowing(accessToken: token, id: model.id);
    return BorrowingModel.fromApiJson(await _apiClient.getBorrowingById(accessToken: token, id: model.id));
  }

  Future<String> _ownMemberId(String token) async {
    final profile = await _apiClient.getMyProfile(accessToken: token);
    return profile['id'] as String;
  }

  Future<String> _requireAccessToken() async {
    final token = await _accessTokenProvider();
    if (token == null) throw const UnexpectedException('No active session.');
    return token;
  }
}
