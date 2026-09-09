import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/preferences/onboarding_preference.dart';
import '../../../../core/storage/secure_session_storage.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_member.dart';
import '../../domain/usecases/restore_session.dart';
part 'auth_providers.g.dart';


// Data Infrastructure Layer
@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) => AuthLocalDataSourceImpl();

@riverpod
SecureSessionStorage secureSessionStorage(Ref ref) => const SecureSessionStorage(FlutterSecureStorage());

@riverpod
OnboardingPreference onboardingPreference(Ref ref) => OnboardingPreference();


// Repository Layer
@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.read(authLocalDataSourceProvider),
  ref.read(secureSessionStorageProvider),
);


// Business Layer
@riverpod
LoginUser loginUserUseCase(Ref ref) => LoginUser(ref.read(authRepositoryProvider));

@riverpod
RegisterMember registerMemberUseCase(Ref ref) => RegisterMember(ref.read(authRepositoryProvider));

@riverpod
RestoreSession restoreSessionUseCase(Ref ref) => RestoreSession(ref.read(authRepositoryProvider));

@riverpod
LogoutUser logoutUserUseCase(Ref ref) => LogoutUser(ref.read(authRepositoryProvider));

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthSession?> build() async {
    final useCase = ref.read(restoreSessionUseCaseProvider);
    final result = await useCase();
    return result.match(
      (failure) => null, // couldn't restore -> treat as signed out, not an error
      (session) => session,
    );
  }


  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final useCase = ref.read(loginUserUseCaseProvider);
    final result = await useCase(email: email, password: password);
    if (!ref.mounted) return;
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
    if (!ref.mounted) return;
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (session) => AsyncData(session),
    );
  }

   Future<void> logout() async {
    final useCase = ref.read(logoutUserUseCaseProvider);
    await useCase(); // best-effort clear; force local state to signed-out regardless
    if (!ref.mounted) return;
    state = const AsyncData(null);
  }
}