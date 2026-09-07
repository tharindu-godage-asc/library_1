import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/bootstrap/app_bootstrap_provider.dart';
import 'core/navigation/auth_gate.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: LibraryApp()));
}

class LibraryApp extends ConsumerWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);
    return MaterialApp(
      title: 'BooksnU',
      theme: AppTheme.light,
      home: bootstrap.when(
        // SplashScreen used exactly as its own doc comment anticipated:
        // "Set to null-safe no-op if you're driving navigation from
        // session-restore logic instead" — onFinished is simply omitted.
        loading: () => const SplashScreen(),
        error: (_, _) => const AuthGate(), // fail safe: never strand the user on a broken splash
        data: (destination) => switch (destination) {
          BootstrapDestination.onboarding => const OnboardingScreen(),
          BootstrapDestination.login || BootstrapDestination.home => const AuthGate(),
        },
      ),
    );
  }
}