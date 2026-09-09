import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// NOTE: conceptually this belongs to Borrowings (it's driven by due
/// dates on a borrowing record), not Books. Kept here for now alongside
/// the other temporary mock content in BooksScreen — move it once
/// Borrowings exists for real.
class ReminderBanner extends StatelessWidget {
  const ReminderBanner({
    super.key,
    required this.bookTitle,
    required this.dueInDays,
    required this.onRenew,
  });

  final String bookTitle;
  final int dueInDays;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: AppColors.textOnPrimary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reminder', style: AppTextStyles.label),
                Text(
                  '$bookTitle is due in $dueInDays days',
                  style: AppTextStyles.bodyMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: onRenew,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              elevation: 0,
            ),
            child: const Text('Renew'),
          ),
        ],
      ),
    );
  }
}