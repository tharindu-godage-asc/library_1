import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _nameError, _emailError, _phoneError, _passwordError, _confirmError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _nameError = name.isEmpty ? 'Full name is required' : null;
      _emailError = email.isEmpty
          ? 'Email is required'
          : !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
              ? 'Enter a valid email'
              : null;
      _phoneError = phone.isEmpty ? 'Contact number is required' : null;
      _passwordError = password.length < 6 ? 'Password must be at least 6 characters' : null;
      // Confirm-password match is a presentation-only check — it's never
      // meaningful to send "did these two fields match" to a backend.
      _confirmError = confirm != password ? 'Passwords do not match' : null;
    });

    return [_nameError, _emailError, _phoneError, _passwordError, _confirmError].every((e) => e == null);
  }

  String _messageFor(Failure failure) => switch (failure) {
        EmailAlreadyExistsFailure() => failure.message,
        _ => 'Something went wrong. Please try again.',
      };

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AppGradientScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text('Create account', style: AppTextStyles.headingLg),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(label: 'Full Name', controller: _nameController, errorText: _nameError),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Contact Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              errorText: _phoneError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              errorText: _passwordError,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Confirm Password',
              controller: _confirmController,
              obscureText: true,
              errorText: _confirmError,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (authState.hasError) ...[
              Text(
                _messageFor(authState.error as Failure),
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.danger),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            AppButton(
              label: 'Register',
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () {
                      if (_validate()) {
                        ref.read(authControllerProvider.notifier).register(
                              fullName: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              password: _passwordController.text,
                            );
                      }
                    },
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