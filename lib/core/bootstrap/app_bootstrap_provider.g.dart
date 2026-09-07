// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_bootstrap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appBootstrap)
final appBootstrapProvider = AppBootstrapProvider._();

final class AppBootstrapProvider
    extends
        $FunctionalProvider<
          AsyncValue<BootstrapDestination>,
          BootstrapDestination,
          FutureOr<BootstrapDestination>
        >
    with
        $FutureModifier<BootstrapDestination>,
        $FutureProvider<BootstrapDestination> {
  AppBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBootstrapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBootstrapHash();

  @$internal
  @override
  $FutureProviderElement<BootstrapDestination> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BootstrapDestination> create(Ref ref) {
    return appBootstrap(ref);
  }
}

String _$appBootstrapHash() => r'84de7276c62b70e76790158c232ba333711d8dba';
