import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/book_local_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/usecases/get_book_by_id.dart';
import '../../domain/usecases/get_books.dart';

part 'book_providers.g.dart';

@Riverpod(keepAlive: true)
BookLocalDataSource bookLocalDataSource(Ref ref) => BookLocalDataSourceImpl();

@Riverpod(keepAlive: true)
BookRepository bookRepository(Ref ref) =>
    BookRepositoryImpl(ref.read(bookLocalDataSourceProvider));

@riverpod
GetBooks getBooksUseCase(Ref ref) => GetBooks(ref.read(bookRepositoryProvider));

@riverpod
GetBookById getBookByIdUseCase(Ref ref) => GetBookById(ref.read(bookRepositoryProvider));

/// AsyncNotifier because it's the generated-code equivalent of the old
/// FutureProvider — `build()` runs once, result is cached, and
/// `ref.invalidateSelf()` (or `ref.invalidate(bookListProvider)` from
/// outside) re-runs it. `.match()` unwraps the Either right here so
/// nothing downstream has to think about Left/Right — the UI only ever
/// sees a plain `AsyncValue<List<Book>>`, same as before this change.
@riverpod
class BookList extends _$BookList {
  @override
  Future<List<Book>> build() async {
    final useCase = ref.read(getBooksUseCaseProvider);
    final result = await useCase();
    return result.match(
      (failure) => throw Exception(failure.message),
      (books) => books,
    );
  }
}

@riverpod
Future<Book> bookById(Ref ref, String id) async {
  final useCase = ref.read(getBookByIdUseCaseProvider);
  final result = await useCase(id);
  return result.match(
    (failure) => throw Exception(failure.message),
    (book) => book,
  );
}