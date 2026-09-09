import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Generic illustration + heading + message + optional actions, shared by
/// every global error screen (no internet / server error / not found) and
/// every empty-state screen (no books / no borrowings / no notifications).
class IllustratedStateView extends StatelessWidget {
  const IllustratedStateView({
    super.key,
    required this.illustrationAsset,
    required this.heading,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String illustrationAsset;
  final String heading;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(illustrationAsset, height: 160),
            const SizedBox(height: AppSpacing.xl),
            Text(heading, style: AppTextStyles.headingLg, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
            if (primaryLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: primaryLabel!, onPressed: onPrimary),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel!, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
