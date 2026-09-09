import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Mirrors the Borrowing statuses from the API reference:
/// Borrowed | Returned | Overdue — plus Available, used on Book details.
enum BadgeStatus { available, borrowed, returned, overdue }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final BadgeStatus status;

  (Color bg, Color fg, String label) get _style => switch (status) {
        BadgeStatus.available => (AppColors.successBg, AppColors.success, 'Available'),
        BadgeStatus.returned => (AppColors.successBg, AppColors.success, 'Returned'),
        BadgeStatus.borrowed => (AppColors.warningBg, AppColors.warning, 'Borrowed'),
        BadgeStatus.overdue => (AppColors.dangerBg, AppColors.danger, 'Overdue'),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}