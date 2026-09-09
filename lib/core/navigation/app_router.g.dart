// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single guard between the Auth Stack (`/login`, `/login/register`)
/// and the Main Stack (`/home`, ...). Replaces the old AuthGate widget —
/// no screen navigates to Home or back to Login on its own anymore;
/// changing auth state is enough, and this is the only place that reacts.

@ProviderFor(router)
final routerProvider = RouterProvider._();

/// The single guard between the Auth Stack (`/login`, `/login/register`)
/// and the Main Stack (`/home`, ...). Replaces the old AuthGate widget —
/// no screen navigates to Home or back to Login on its own anymore;
/// changing auth state is enough, and this is the only place that reacts.

final class RouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The single guard between the Auth Stack (`/login`, `/login/register`)
  /// and the Main Stack (`/home`, ...). Replaces the old AuthGate widget —
  /// no screen navigates to Home or back to Login on its own anymore;
  /// changing auth state is enough, and this is the only place that reacts.
  RouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return router(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerHash() => r'36189f729d5def0844d7bf6cea588dc10e73eb26';
