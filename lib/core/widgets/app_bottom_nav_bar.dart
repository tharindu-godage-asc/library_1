import 'package:flutter/material.dart';

class AppNavItem {
  const AppNavItem({required this.icon, required this.label, this.selectedIcon});
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
}

/// Thin wrapper around Material's NavigationBar — same public API as
/// before, so call sites (BooksScreen, and later Borrowings/Profile
/// screens) don't need to change. Real navigation wiring still happens
/// in the Routing phase, not here.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: items
          .map((item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon ?? item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }
}