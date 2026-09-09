import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connectivity/connectivity_provider.dart';
import '../../widgets/illustrated_state_view.dart';
import '../app_error_type.dart';
import '../failure.dart';

/// Drop-in replacement for the old text-only `ErrorView`. Picks the
/// illustrated screen to show for a failed Riverpod `AsyncValue`: always
/// prefers the No-Internet illustration while offline (regardless of the
/// underlying failure), otherwise maps the [Failure] subtype to the
/// matching 404/500/unexpected illustration.
class ErrorStateView extends ConsumerWidget {
  const ErrorStateView({super.key, required this.error, required this.onRetry, this.onSecondaryAction});

  final Object? error;
  final VoidCallback onRetry;
  final VoidCallback? onSecondaryAction;

  Failure get _failure => error is Failure ? error as Failure : UnexpectedFailure(error.toString());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider).value;

    if (connectivity == AppConnectivityStatus.offline) {
      return IllustratedStateView(
        illustrationAsset: 'assets/illustrations/illustration-no-connection.png',
        heading: 'No Internet Connection',
        message: "Check your connection and try again. Anything you've already saved will still be here.",
        primaryLabel: 'Try Again',
        onPrimary: onRetry,
        secondaryLabel: onSecondaryAction != null ? 'Go Back' : null,
        onSecondary: onSecondaryAction,
      );
    }

    return switch (appErrorTypeFrom(_failure)) {
      AppErrorType.notFound => IllustratedStateView(
          illustrationAsset: 'assets/illustrations/illustration-not-found.png',
          heading: "We Couldn't Find That",
          message: _failure.message,
          primaryLabel: 'Try Again',
          onPrimary: onRetry,
        ),
      AppErrorType.server || AppErrorType.unexpected => IllustratedStateView(
          illustrationAsset: 'assets/illustrations/illustration-server-error.png',
          heading: 'Something Went Wrong',
          message: 'We hit a snag loading this page. Please try again in a moment.',
          primaryLabel: 'Try Again',
          onPrimary: onRetry,
        ),
    };
  }
}
