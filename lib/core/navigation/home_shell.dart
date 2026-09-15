import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Shared shell for the 3 bottom-nav tabs (Borrowings/Books/Profile).
/// Each branch keeps its own Navigator alive inside the IndexedStack
/// `navigationShell` wraps, so switching tabs preserves each tab's
/// scroll position and in-progress state (e.g. Books' search field)
/// instead of tearing the screen down and rebuilding it — unlike the
/// old per-screen `context.go('/home/...')` switch this replaces.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        items: const [
          AppNavItem(icon: Icons.swap_vert, label: 'Borrowings'),
          AppNavItem(icon: Icons.menu_book_outlined, label: 'Books'),
          AppNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
