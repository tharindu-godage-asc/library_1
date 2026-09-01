import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppNavItem {
  const AppNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Purely presentational — takes the current index and a callback.
/// Real navigation wiring happens in Phase: Routing, not here.
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
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          final color = active ? AppColors.primaryPressed : AppColors.textSecondary;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i].icon, color: color, size: 22),
                const SizedBox(height: 2),
                Text(items[i].label, style: AppTextStyles.caption.copyWith(color: color)),
              ],
            ),
          );
        }),
      ),
    );
  }
}