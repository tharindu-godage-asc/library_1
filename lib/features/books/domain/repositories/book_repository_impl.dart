import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../data/datasources/book_mock_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  const BookRepositoryImpl(this._dataSource);
  final BookMockDataSource _dataSource;

  @override
  Future<List<Book>> getBooks() async {
    final models = await _dataSource.fetchBooks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Book> getBookById(String id) async {
    final model = await _dataSource.fetchBookById(id);
    return model.toEntity();
  }
}