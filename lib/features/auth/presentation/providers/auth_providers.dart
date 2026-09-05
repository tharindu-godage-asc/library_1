import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_member.dart';

part 'auth_providers.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) => AuthLocalDataSourceImpl();

@riverpod
AuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.read(authLocalDataSourceProvider));

@riverpod
LoginUser loginUserUseCase(Ref ref) => LoginUser(ref.read(authRepositoryProvider));

@riverpod
RegisterMember registerMemberUseCase(Ref ref) => RegisterMember(ref.read(authRepositoryProvider));

/// Holds the current session as an AsyncValue<AuthSession?>:
///  - AsyncData(null)   -> signed out (the only state possible right now —
///                          there's no persistence yet, so every cold
///                          start begins here; that's next slice's job)
///  - AsyncLoading()    -> a login/register call is in flight
///  - AsyncData(session)-> signed in
///  - AsyncError(...)   -> the last attempt failed; session is still null
@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<AuthSession?> build() => const AsyncData(null);

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final useCase = ref.read(loginUserUseCaseProvider);
    final result = await useCase(email: email, password: password);
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (session) => AsyncData(session),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncLoading();
    final useCase = ref.read(registerMemberUseCaseProvider);
    final result = await useCase(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (session) => AsyncData(session),
    );
  }
}