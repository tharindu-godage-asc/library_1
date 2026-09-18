import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AppGradientScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text('Create account', style: AppTextStyles.headingLg),
            const SizedBox(height: AppSpacing.md),
            // Account details are collected on Keycloak's own hosted sign-up
            // page, not here — this screen only kicks off the redirect.
            const Text(
              "You'll be taken to a secure sign-up page to enter your details.",
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (authState.hasError) ...[
              Text(
                'Something went wrong. Please try again.',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.danger),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: 'Register',
              isLoading: isLoading,
              onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).register(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMd,
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(text: 'Login', style: AppTextStyles.label),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
