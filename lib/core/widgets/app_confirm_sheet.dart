import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// A thin wrapper around Material's showModalBottomSheet — that's the
/// actual "MUI" component giving the dimmed scrim, swipe-to-dismiss, and
/// rounded-top-corner sheet, not something built from primitives.
///
/// Shaped as a static function rather than a widget class, unlike every
/// other core/widgets file so far — that's deliberate, not inconsistent:
/// showDialog/showModalBottomSheet are themselves imperative "ask and
/// await an answer" functions, not things you place in a widget tree, so
/// this follows that same shape rather than fighting it.
class AppConfirmSheet {
  const AppConfirmSheet._(); // not meant to be instantiated

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.backgroundTop,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                ),
              ),
              Text(title, style: AppTextStyles.headingMd, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelLabel,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}