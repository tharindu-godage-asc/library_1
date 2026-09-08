import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

part 'app_bootstrap_provider.g.dart';

enum BootstrapDestination { onboarding, login, home }

// keepAlive: this is a run-once-and-cache-forever decision, same category
// as AuthController. It must never recompute after cold start — see the
// `ref.read`, not `ref.watch`, comment below — so it can't be left to
// autoDispose based on incidental subscribers (e.g. the router's
// ref.listen); it needs to be alive on its own terms.
@Riverpod(keepAlive: true)
Future<BootstrapDestination> appBootstrap(Ref ref) async {
  // Preserves the splash screen's original 2.4s brand-timing hold, now
  // driven by real state instead of a bare timer + callback.
  final minimumHold = Future.delayed(const Duration(milliseconds: 2400));

  final onboardingPref = ref.read(onboardingPreferenceProvider);
  final hasOnboarded = await onboardingPref.hasCompletedOnboarding();

  BootstrapDestination destination;
  if (!hasOnboarded) {
    destination = BootstrapDestination.onboarding;
  } else {
    // Deliberately `ref.read`, not `ref.watch`. This must run exactly
    // once, at true cold start — if it watched authControllerProvider,
    // every later login/logout would re-trigger this whole function,
    // including the 2.4s minimum-hold delay, flashing the splash back up
    // mid-session. Runtime sign-in/out transitions are handled entirely by
    // AppRouter's redirect once this cold-start decision is made; this
    // destination is never consulted again after the app leaves /splash.
    final session = await ref.read(authControllerProvider.future);
    destination = session != null ? BootstrapDestination.home : BootstrapDestination.login;
  }

  await minimumHold;
  return destination;
}