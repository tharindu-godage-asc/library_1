// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authLocalDataSource)
final authLocalDataSourceProvider = AuthLocalDataSourceProvider._();

final class AuthLocalDataSourceProvider
    extends
        $FunctionalProvider<
          AuthLocalDataSource,
          AuthLocalDataSource,
          AuthLocalDataSource
        >
    with $Provider<AuthLocalDataSource> {
  AuthLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthLocalDataSource create(Ref ref) {
    return authLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLocalDataSource>(value),
    );
  }
}

String _$authLocalDataSourceHash() =>
    r'c8ddb83d401afd75f7a248093d4bcbe2a2ef454e';

@ProviderFor(secureSessionStorage)
final secureSessionStorageProvider = SecureSessionStorageProvider._();

final class SecureSessionStorageProvider
    extends
        $FunctionalProvider<
          SecureSessionStorage,
          SecureSessionStorage,
          SecureSessionStorage
        >
    with $Provider<SecureSessionStorage> {
  SecureSessionStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureSessionStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureSessionStorageHash();

  @$internal
  @override
  $ProviderElement<SecureSessionStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureSessionStorage create(Ref ref) {
    return secureSessionStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureSessionStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureSessionStorage>(value),
    );
  }
}

String _$secureSessionStorageHash() =>
    r'9f1a8f89d256e9c8affed74e50ab3415e66459ee';

@ProviderFor(onboardingPreference)
final onboardingPreferenceProvider = OnboardingPreferenceProvider._();

final class OnboardingPreferenceProvider
    extends
        $FunctionalProvider<
          OnboardingPreference,
          OnboardingPreference,
          OnboardingPreference
        >
    with $Provider<OnboardingPreference> {
  OnboardingPreferenceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingPreferenceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingPreferenceHash();

  @$internal
  @override
  $ProviderElement<OnboardingPreference> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingPreference create(Ref ref) {
    return onboardingPreference(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingPreference value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingPreference>(value),
    );
  }
}

String _$onboardingPreferenceHash() =>
    r'af3533aac1c93408d71c39da0d8d635923139d51';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'199761b11b59ee2a0e1591b355ec5b16a61ec5e0';

@ProviderFor(loginUserUseCase)
final loginUserUseCaseProvider = LoginUserUseCaseProvider._();

final class LoginUserUseCaseProvider
    extends $FunctionalProvider<LoginUser, LoginUser, LoginUser>
    with $Provider<LoginUser> {
  LoginUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginUserUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUser create(Ref ref) {
    return loginUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUser>(value),
    );
  }
}

String _$loginUserUseCaseHash() => r'13f191851bb7010f1cf05dd0cf8bd184185a58db';

@ProviderFor(registerMemberUseCase)
final registerMemberUseCaseProvider = RegisterMemberUseCaseProvider._();

final class RegisterMemberUseCaseProvider
    extends $FunctionalProvider<RegisterMember, RegisterMember, RegisterMember>
    with $Provider<RegisterMember> {
  RegisterMemberUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerMemberUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerMemberUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterMember> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RegisterMember create(Ref ref) {
    return registerMemberUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterMember value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterMember>(value),
    );
  }
}

String _$registerMemberUseCaseHash() =>
    r'283d5f4bd6d7140e0a47e6f0cfec3721da8ec8d6';

@ProviderFor(restoreSessionUseCase)
final restoreSessionUseCaseProvider = RestoreSessionUseCaseProvider._();

final class RestoreSessionUseCaseProvider
    extends $FunctionalProvider<RestoreSession, RestoreSession, RestoreSession>
    with $Provider<RestoreSession> {
  RestoreSessionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreSessionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreSessionUseCaseHash();

  @$internal
  @override
  $ProviderElement<RestoreSession> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RestoreSession create(Ref ref) {
    return restoreSessionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreSession>(value),
    );
  }
}

String _$restoreSessionUseCaseHash() =>
    r'3ff6ae305fd9b2f1e8f123d842bc5aac600de7c8';

@ProviderFor(logoutUserUseCase)
final logoutUserUseCaseProvider = LogoutUserUseCaseProvider._();

final class LogoutUserUseCaseProvider
    extends $FunctionalProvider<LogoutUser, LogoutUser, LogoutUser>
    with $Provider<LogoutUser> {
  LogoutUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logoutUserUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logoutUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<LogoutUser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogoutUser create(Ref ref) {
    return logoutUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogoutUser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogoutUser>(value),
    );
  }
}

String _$logoutUserUseCaseHash() => r'4339d832fb3306241ebb26b2317dde9387e704d0';

/// Holds the current session as an `AsyncValue<AuthSession?>`:
///  - AsyncData(null)   -> signed out (the only state possible right now —
///                          there's no persistence yet, so every cold
///                          start begins here; that's next slice's job)
///  - AsyncLoading()    -> a login/register call is in flight
///  - AsyncData(session)-> signed in
///  - AsyncError(...)   -> the last attempt failed; session is still null

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Holds the current session as an `AsyncValue<AuthSession?>`:
///  - AsyncData(null)   -> signed out (the only state possible right now —
///                          there's no persistence yet, so every cold
///                          start begins here; that's next slice's job)
///  - AsyncLoading()    -> a login/register call is in flight
///  - AsyncData(session)-> signed in
///  - AsyncError(...)   -> the last attempt failed; session is still null
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthSession?> {
  /// Holds the current session as an `AsyncValue<AuthSession?>`:
  ///  - AsyncData(null)   -> signed out (the only state possible right now —
  ///                          there's no persistence yet, so every cold
  ///                          start begins here; that's next slice's job)
  ///  - AsyncLoading()    -> a login/register call is in flight
  ///  - AsyncData(session)-> signed in
  ///  - AsyncError(...)   -> the last attempt failed; session is still null
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'f70a70544b2c9eefe28ba990914a68cc7a6c458c';

/// Holds the current session as an `AsyncValue<AuthSession?>`:
///  - AsyncData(null)   -> signed out (the only state possible right now —
///                          there's no persistence yet, so every cold
///                          start begins here; that's next slice's job)
///  - AsyncLoading()    -> a login/register call is in flight
///  - AsyncData(session)-> signed in
///  - AsyncError(...)   -> the last attempt failed; session is still null

abstract class _$AuthController extends $AsyncNotifier<AuthSession?> {
  FutureOr<AuthSession?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthSession?>, AuthSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthSession?>, AuthSession?>,
              AsyncValue<AuthSession?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
