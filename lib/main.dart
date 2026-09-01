import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_button.dart';
import 'core/widgets/app_gradient_scaffold.dart';
import 'core/widgets/app_text_field.dart';
import 'core/widgets/status_badge.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_spacing.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BooksnU',
      theme: AppTheme.light,
      home: const _ComponentGalleryScreen(),
    );
  }
}

/// Temporary — proves the theme/widgets work before Phase 2 replaces
/// this with the real Books screen. Delete once Books is wired up.
class _ComponentGalleryScreen extends StatelessWidget {
  const _ComponentGalleryScreen();

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BooksnU', style: AppTextStyles.displayLg),
            const SizedBox(height: AppSpacing.lg),
            const AppTextField(label: 'Email', hintText: 'you@email.com'),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'Login', onPressed: () {}),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Cancel', variant: AppButtonVariant.text, onPressed: () {}),
            const SizedBox(height: AppSpacing.lg),
            const Row(
              children: [
                StatusBadge(status: BadgeStatus.borrowed),
                SizedBox(width: 8),
                StatusBadge(status: BadgeStatus.returned),
                SizedBox(width: 8),
                StatusBadge(status: BadgeStatus.overdue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}