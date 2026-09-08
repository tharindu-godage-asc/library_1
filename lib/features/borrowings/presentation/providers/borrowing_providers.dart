import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../data/datasources/borrowing_local_datasource.dart';
import '../../data/repositories/borrowing_repository_impl.dart';
import '../../domain/entities/borrowing.dart';
import '../../domain/repositories/borrowing_repository.dart';
import '../../domain/usecases/borrow_book.dart';
import '../../domain/usecases/return_borrowing.dart';

part 'borrowing_providers.g.dart';

@Riverpod(keepAlive: true)
BorrowingLocalDataSource borrowingLocalDataSource(Ref ref) => BorrowingLocalDataSourceImpl();

@Riverpod(keepAlive: true)
BorrowingRepository borrowingRepository(Ref ref) =>
    BorrowingRepositoryImpl(ref.read(borrowingLocalDataSourceProvider));

@riverpod
BorrowBook borrowBookUseCase(Ref ref) =>
    BorrowBook(ref.read(bookRepositoryProvider), ref.read(borrowingRepositoryProvider));

@riverpod
ReturnBorrowing returnBorrowingUseCase(Ref ref) =>
    ReturnBorrowing(ref.read(bookRepositoryProvider), ref.read(borrowingRepositoryProvider));

/// Re-derives memberId from the current session on every (re)build — if a
/// different member ever logs in during the same app lifetime, this
/// naturally refetches for them instead of leaking the previous
/// member's data forward.
@riverpod
Future<List<Borrowing>> myBorrowings(Ref ref) async {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) return const [];
  final repository = ref.read(borrowingRepositoryProvider);
  final result = await repository.getBorrowingsForMember(session.userId);
  return result.match((f) => throw Exception(f.message), (list) => list);
}

@riverpod
Future<Borrowing> borrowingById(Ref ref, String id) async {
  final repository = ref.read(borrowingRepositoryProvider);
  final result = await repository.getBorrowingById(id);
  return result.match((f) => throw Exception(f.message), (b) => b);
}

/// One-shot action state for the Confirm Borrowing screen. Deliberately
/// plain @riverpod (autoDispose) — unlike the data-holding providers
/// above, fresh state each time you open Confirm for a different book is
/// exactly what's wanted here, not a bug to guard against.
@riverpod
class BorrowActionController extends _$BorrowActionController {
  @override
  Future<Borrowing?> build() async => null;

  Future<void> borrow({required String bookId, required String memberId}) async {
    state = const AsyncLoading();
    final useCase = ref.read(borrowBookUseCaseProvider);
    final result = await useCase(bookId: bookId, memberId: memberId);
    if (!ref.mounted) return;
    result.match(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (borrowing) {
        state = AsyncData(borrowing);
        // Refresh everything this action just made stale.
        ref.invalidate(bookListProvider);
        ref.invalidate(bookByIdProvider(bookId));
        ref.invalidate(myBorrowingsProvider);
      },
    );
  }
}

@riverpod
class ReturnActionController extends _$ReturnActionController {
  @override
  Future<Borrowing?> build() async => null;

  Future<void> returnBook(String borrowingId, String bookId) async {
    state = const AsyncLoading();
    final useCase = ref.read(returnBorrowingUseCaseProvider);
    final result = await useCase(borrowingId);
    if (!ref.mounted) return;
    result.match(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (borrowing) {
        state = AsyncData(borrowing);
        ref.invalidate(bookListProvider);
        ref.invalidate(bookByIdProvider(bookId));
        ref.invalidate(myBorrowingsProvider);
        ref.invalidate(borrowingByIdProvider(borrowingId));
      },
    );
  }
}