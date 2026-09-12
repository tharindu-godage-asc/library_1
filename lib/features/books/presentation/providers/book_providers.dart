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

@riverpod
class BookList extends _$BookList {
  @override
  Future<List<Book>> build() async {
    final useCase = ref.read(getBooksUseCaseProvider);
    final result = await useCase();
    return result.match(
      (failure) => throw failure,
      (books) => books,
    );
  }
}

@riverpod
Future<Book> bookById(Ref ref, String id) async {
  final useCase = ref.read(getBookByIdUseCaseProvider);
  final result = await useCase(id);
  return result.match(
    (failure) => throw failure,
    (book) => book,
  );
}

/*
 * Riverpod Architecture & Dependency Injection Map:
 * 
 * 1. Data Layer Providers:
 *    - bookLocalDataSourceProvider: Constructs the concrete BookLocalDataSourceImpl.
 *    - bookRepositoryProvider: Constructs BookRepositoryImpl, injecting the local data source.
 * 
 * 2. Domain Layer (Use Case) Providers:
 *    - getBooksUseCaseProvider / getBookByIdUseCaseProvider: Instantiates the GetBooks and GetBookById use cases, injecting the book repository.
 * 
 * 3. Presentation Layer (State Management) Providers:
 *    - bookListProvider: AsyncNotifier that executes GetBooks() once, caches the collection, and unwraps the Either type so UI widgets cleanly consume a plain AsyncValue<List<Book>>.
 *    - bookByIdProvider(id): Family provider that executes GetBookById(id) for a specific identifier, handling error/success unwrapping for individual views.
 */