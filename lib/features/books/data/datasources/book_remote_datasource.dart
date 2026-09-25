import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/book_model.dart';
import 'book_local_datasource.dart';

typedef AccessTokenProvider = Future<String?> Function();

/// Backs the [BookLocalDataSource] contract with Library.Api instead of the
/// bundled JSON. Library.Api's book response has no image property yet, so
/// every model comes back with a null imageUrl and the UI shows its
/// placeholder cover — wire the field into [BookModel.fromJson] once the
/// backend adds it.
class BookRemoteDataSourceImpl implements BookLocalDataSource {
  const BookRemoteDataSourceImpl(this._apiClient, this._accessTokenProvider);
  final ApiClient _apiClient;
  final AccessTokenProvider _accessTokenProvider;

  static const _pageSize = 50;

  /// The catalogue screens work off the full list (search is client-side),
  /// so this walks every page rather than returning just the first.
  @override
  Future<List<BookModel>> fetchBooks() async {
    final token = await _requireAccessToken();
    final books = <BookModel>[];
    var page = 1;
    var totalPages = 1;
    do {
      final json = await _apiClient.getBooksPage(
        accessToken: token,
        pageNumber: page,
        pageSize: _pageSize,
      );
      final items = (json['items'] as List).cast<Map<String, dynamic>>();
      books.addAll(items.map(BookModel.fromJson));
      totalPages = json['totalPages'] as int;
      page++;
    } while (page <= totalPages);
    return books;
  }

  @override
  Future<BookModel> fetchBookById(String id) async {
    final token = await _requireAccessToken();
    final json = await _apiClient.getBookById(accessToken: token, id: id);
    return BookModel.fromJson(json);
  }

  /// Library.Api has no endpoint for this yet, and borrowing is still
  /// running on local/mock data (see the books-backend-integration spec's
  /// non-goals). Returns the model unchanged so borrow/return flows don't
  /// fail — the copy-count change simply isn't persisted server-side.
  @override
  Future<BookModel> updateBook(BookModel model) async => model;

  Future<String> _requireAccessToken() async {
    final token = await _accessTokenProvider();
    if (token == null) throw const UnexpectedException('No active session.');
    return token;
  }
}
