import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

enum AppConnectivityStatus { online, offline }

AppConnectivityStatus _statusFrom(List<ConnectivityResult> results) =>
    results.every((r) => r == ConnectivityResult.none) ? AppConnectivityStatus.offline : AppConnectivityStatus.online;

/// Global, app-wide online/offline signal. `keepAlive` so the
/// subscription survives regardless of which screen is currently
/// watching it — every screen's [ErrorStateView] reads the same stream.
@Riverpod(keepAlive: true)
Stream<AppConnectivityStatus> connectivityStatus(Ref ref) async* {
  final connectivity = Connectivity();
  yield _statusFrom(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_statusFrom);
}
