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
import '../../features/borrowings/presentation/screens/borrowing_details_screen.dart';
import '../../features/borrowings/presentation/screens/my_borrowings_screen.dart';
import '../bootstrap/app_bootstrap_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/members/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../error/widgets/not_found_route_screen.dart';
import 'home_shell.dart';

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
///
/// Navigation rule for screens under the Main Stack:
///  - Switching bottom-nav tabs -> `navigationShell.goBranch(i)` (only
///    HomeShell does this). Never `context.go('/home/...')` for a tab
///    switch — that's what tore down each tab's state before this file
///    grew a `StatefulShellRoute`.
///  - Drilling into more content (a book, a borrowing, search results,
///    notifications) -> `context.push(...)`, so back returns you to
///    where you were.
///  - Deliberately resetting a tab back to its root from an error/empty
///    state (e.g. "Browse Books" after an empty Borrowings list, or from
///    [NotFoundRouteScreen]) -> `context.go('/home')` is correct here,
///    not a bug — the intent is "start fresh at Books' root", not
///    "preserve wherever Books was last left".
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

    // Ongoing guard between the two stacks. Onboarding's only exit is
    // OnboardingScreen._finish()'s own explicit context.go('/login') call
    // (see that method's comment) — not re-derived here.
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
    errorBuilder: (context, state) => const NotFoundRouteScreen(),
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
      // One StatefulShellBranch per bottom-nav tab, in the same order as
      // HomeShell's AppNavItem list (Borrowings=0, Books=1, Profile=2) so
      // `navigationShell.currentIndex` lines up with the nav bar's
      // `currentIndex` with no per-screen bookkeeping. Each branch keeps
      // its own Navigator alive in the IndexedStack HomeShell wraps, so
      // switching tabs preserves scroll position / in-progress state
      // instead of tearing the screen down like the old context.go(...)
      // tab switch did.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/borrowings',
                builder: (_, _) => const MyBorrowingsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => BorrowingDetailsScreen(borrowingId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
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
                  GoRoute(path: 'notifications', builder: (_, _) => const NotificationsScreen()),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home/profile', builder: (_, _) => const ProfileScreen()),
            ],
          ),
        ],
      ),
    ],
  );
}
