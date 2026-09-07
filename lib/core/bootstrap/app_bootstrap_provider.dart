import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

part 'app_bootstrap_provider.g.dart';

enum BootstrapDestination { onboarding, login, home }

@riverpod
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
    // mid-session. Runtime sign-in/out transitions are handled by
    // explicit navigation at the screen level instead (LoginScreen's
    // ref.listen; the logout button below). The root only owns the
    // COLD-START decision reactively — full state-driven navigation for
    // every transition is still go_router's job, in Phase 14.
    final session = await ref.read(authControllerProvider.future);
    destination = session != null ? BootstrapDestination.home : BootstrapDestination.login;
  }

  await minimumHold;
  return destination;
}