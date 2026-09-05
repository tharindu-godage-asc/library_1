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

String _$authRepositoryHash() => r'08d04b56bca65d6cbedb92bc8285ffc203eeded2';

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

/// Holds the current session as an AsyncValue<AuthSession?>:
///  - AsyncData(null)   -> signed out (the only state possible right now —
///                          there's no persistence yet, so every cold
///                          start begins here; that's next slice's job)
///  - AsyncLoading()    -> a login/register call is in flight
///  - AsyncData(session)-> signed in
///  - AsyncError(...)   -> the last attempt failed; session is still null

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Holds the current session as an AsyncValue<AuthSession?>:
///  - AsyncData(null)   -> signed out (the only state possible right now —
///                          there's no persistence yet, so every cold
///                          start begins here; that's next slice's job)
///  - AsyncLoading()    -> a login/register call is in flight
///  - AsyncData(session)-> signed in
///  - AsyncError(...)   -> the last attempt failed; session is still null
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AsyncValue<AuthSession?>> {
  /// Holds the current session as an AsyncValue<AuthSession?>:
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
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AuthSession?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AuthSession?>>(value),
    );
  }
}

String _$authControllerHash() => r'b0436806c7855cdf2e00f5870753902f8144dea8';

/// Holds the current session as an AsyncValue<AuthSession?>:
///  - AsyncData(null)   -> signed out (the only state possible right now —
///                          there's no persistence yet, so every cold
///                          start begins here; that's next slice's job)
///  - AsyncLoading()    -> a login/register call is in flight
///  - AsyncData(session)-> signed in
///  - AsyncError(...)   -> the last attempt failed; session is still null

abstract class _$AuthController extends $Notifier<AsyncValue<AuthSession?>> {
  AsyncValue<AuthSession?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AuthSession?>, AsyncValue<AuthSession?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthSession?>, AsyncValue<AuthSession?>>,
              AsyncValue<AuthSession?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
