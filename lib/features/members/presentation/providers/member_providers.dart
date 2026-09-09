import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/member_local_datasource.dart';
import '../../data/repositories/member_repository_impl.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/usecases/get_member.dart';
import '../../domain/usecases/update_member.dart';

part 'member_providers.g.dart';

@Riverpod(keepAlive: true)
MemberLocalDataSource memberLocalDataSource(Ref ref) => MemberLocalDataSourceImpl();

@Riverpod(keepAlive: true)
MemberRepository memberRepository(Ref ref) => MemberRepositoryImpl(ref.read(memberLocalDataSourceProvider));

@riverpod
GetMember getMemberUseCase(Ref ref) => GetMember(ref.read(memberRepositoryProvider));

@riverpod
UpdateMember updateMemberUseCase(Ref ref) => UpdateMember(ref.read(memberRepositoryProvider));

/// The signed-in user's own profile — Admin or Member alike, same
/// provider, since the mobile app treats both identically per the scope
/// we settled on. Re-derives from the current session, same pattern as
/// myBorrowingsProvider.
@riverpod
Future<Member?> myProfile(Ref ref) async {
  final session = ref.watch(authControllerProvider).value;
  if (session == null) return null;
  final useCase = ref.read(getMemberUseCaseProvider);
  final result = await useCase(session.userId);
  return result.match((f) => throw Exception(f.message), (m) => m);
}

@riverpod
class EditProfileController extends _$EditProfileController {
  @override
  Future<Member?> build() async => null;

  Future<void> save(Member updated) async {
    state = const AsyncLoading();
    final useCase = ref.read(updateMemberUseCaseProvider);
    final result = await useCase(updated);
    if (!ref.mounted) return;
    result.match(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (member) {
        state = AsyncData(member);
        ref.invalidate(myProfileProvider);
      },
    );
  }
}