import 'dart:async';

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
import '../../domain/usecases/refresh_session.dart';
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
RefreshSession refreshSessionUseCase(Ref ref) => RefreshSession(ref.read(authRepositoryProvider));

@riverpod
LogoutUser logoutUserUseCase(Ref ref) => LogoutUser(ref.read(authRepositoryProvider));

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  Timer? _refreshTimer;
  static const _refreshLeadTime = Duration(seconds: 30);

  @override
  Future<AuthSession?> build() async {
    ref.onDispose(() => _refreshTimer?.cancel());

    final useCase = ref.read(restoreSessionUseCaseProvider);
    final result = await useCase();
    return result.match(
      (failure) async => null, // couldn't restore -> treat as signed out, not an error
      (session) async {
        if (session == null) return null;

        if (session.isRefreshTokenExpired) {
          await ref.read(logoutUserUseCaseProvider)(); // clear the dead session, stay signed out
          return null;
        }
        if (session.isAccessTokenExpired) {
          // Stale access token but the refresh token is still good — refresh eagerly
          // rather than exposing a session that would fail on its very first use.
          final refreshed = await ref.read(refreshSessionUseCaseProvider)();
          return refreshed.match((failure) => null, (fresh) {
            _scheduleRefresh(fresh);
            return fresh;
          });
        }
        _scheduleRefresh(session);
        return session;
      },
    );
  }

  void _scheduleRefresh(AuthSession session) {
    _refreshTimer?.cancel();
    var delay = session.accessTokenExpiresAt.difference(DateTime.now()) - _refreshLeadTime;
    if (delay.isNegative) delay = Duration.zero;
    _refreshTimer = Timer(delay, _silentRefresh);
  }

  Future<void> _silentRefresh() async {
    final result = await ref.read(refreshSessionUseCaseProvider)();
    if (!ref.mounted) return;
    result.match(
      (failure) {
        _refreshTimer?.cancel();
        _refreshTimer = null;
        state = const AsyncData(null); // forced logout; router redirect reacts automatically
      },
      (session) {
        state = AsyncData(session);
        _scheduleRefresh(session); // keep the loop going
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final useCase = ref.read(loginUserUseCaseProvider);
    final result = await useCase(email: email, password: password);
    if (!ref.mounted) return;
    state = result.match(
      (failure) => AsyncError(failure, StackTrace.current),
      (session) {
        _scheduleRefresh(session);
        return AsyncData(session);
      },
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
      (session) {
        _scheduleRefresh(session);
        return AsyncData(session);
      },
    );
  }

   Future<void> logout() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    final useCase = ref.read(logoutUserUseCaseProvider);
    await useCase(); // best-effort clear; force local state to signed-out regardless
    if (!ref.mounted) return;
    state = const AsyncData(null);
  }
}