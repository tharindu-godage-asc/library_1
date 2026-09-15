// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global, app-wide online/offline signal. `keepAlive` so the
/// subscription survives regardless of which screen is currently
/// watching it — every screen's [ErrorStateView] reads the same stream.

@ProviderFor(connectivityStatus)
final connectivityStatusProvider = ConnectivityStatusProvider._();

/// Global, app-wide online/offline signal. `keepAlive` so the
/// subscription survives regardless of which screen is currently
/// watching it — every screen's [ErrorStateView] reads the same stream.

final class ConnectivityStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppConnectivityStatus>,
          AppConnectivityStatus,
          Stream<AppConnectivityStatus>
        >
    with
        $FutureModifier<AppConnectivityStatus>,
        $StreamProvider<AppConnectivityStatus> {
  /// Global, app-wide online/offline signal. `keepAlive` so the
  /// subscription survives regardless of which screen is currently
  /// watching it — every screen's [ErrorStateView] reads the same stream.
  ConnectivityStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStatusHash();

  @$internal
  @override
  $StreamProviderElement<AppConnectivityStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppConnectivityStatus> create(Ref ref) {
    return connectivityStatus(ref);
  }
}

String _$connectivityStatusHash() =>
    r'd288d7cdc0e6795b47ca947943a6013d8f25606f';
