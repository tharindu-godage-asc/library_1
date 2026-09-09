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
        isAutoDispose: false,
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

String _$appBootstrapHash() => r'c4e3a876b9d12d050798838a9d905b1efc633031';
