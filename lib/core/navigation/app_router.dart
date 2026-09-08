import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/books/presentation/screens/book_details_screen.dart';
import '../../features/books/presentation/screens/book_search_results_screen.dart';
import '../../features/books/presentation/screens/books_screen.dart';
import '../bootstrap/app_bootstrap_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

part 'app_router.g.dart';

/// Bridges Riverpod state changes into go_router's redirect pipeline.
/// go_router only re-runs `redirect` when this notifies (or on an actual
/// navigation), so every provider the guard logic reads from must have a
/// listener here.
class _RouterRefreshNotifier extends ChangeNotifier {
  void ping() => notifyListeners();
}

/// The single guard between the Auth Stack (`/login`, `/login/register`)
/// and the Main Stack (`/home`, ...). Replaces the old AuthGate widget —
/// no screen navigates to Home or back to Login on its own anymore;
/// changing auth state is enough, and this is the only place that reacts.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refresh = _RouterRefreshNotifier();
  ref.listen(appBootstrapProvider, (_, _) => refresh.ping());
  ref.listen(authControllerProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.uri.path;
    final bootstrap = ref.read(appBootstrapProvider);

    if (bootstrap.isLoading) {
      return loc == '/splash' ? null : '/splash';
    }
    if (bootstrap.hasError) {
      // fail-safe: never strand the user on a broken splash
      return (loc == '/login' || loc.startsWith('/login/')) ? null : '/login';
    }

    final destination = bootstrap.requireValue;
    final signedIn = ref.read(authControllerProvider).asData?.value != null;

    // One-shot cold-start decision — fires exactly once, only while still
    // on /splash. `destination` is cached forever by appBootstrapProvider
    // and must never be consulted again after this.
    if (loc == '/splash') {
      if (destination == BootstrapDestination.onboarding) return '/onboarding';
      return signedIn ? '/home' : '/login';
    }

    // Ongoing guard between the two stacks. Onboarding's only exit is its
    // own explicit context.go('/login') call; not re-derived here.
    final onLoginBranch = loc == '/login' || loc.startsWith('/login/');
    final onHomeBranch = loc == '/home' || loc.startsWith('/home/');
    if (signedIn && onLoginBranch) return '/home';
    if (!signedIn && onHomeBranch) return '/login';
    return null;
  }

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
        routes: [
          GoRoute(path: 'register', builder: (_, _) => const RegisterScreen()),
        ],
      ),
      GoRoute(
        path: '/home',
        builder: (_, _) => const BooksScreen(),
        routes: [
          GoRoute(
            path: 'book/:id',
            builder: (_, state) => BookDetailsScreen(bookId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'search',
            builder: (_, state) => BookSearchResultsScreen(initialQuery: state.uri.queryParameters['q'] ?? ''),
          ),
        ],
      ),
    ],
  );
}
