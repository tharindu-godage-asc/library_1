import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/widgets/error_state_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/member.dart';
import '../providers/member_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(myProfileProvider);

    return AppGradientScaffold(
      bottomNavigationBar: AppBottomNavBar(
        items: const [
          AppNavItem(icon: Icons.swap_vert, label: 'Borrowings'),
          AppNavItem(icon: Icons.menu_book_outlined, label: 'Books'),
          AppNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go('/home/borrowings');
          if (i == 1) context.go('/home');
        },
      ),
      body: asyncProfile.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(
          error: e,
          onRetry: () => ref.invalidate(myProfileProvider),
        ),
        data: (member) => member == null
            ? const Center(child: Text('Not signed in.', style: AppTextStyles.bodyMd))
            : _ProfileBody(member: member),
      ),
    );
  }
}

/// One screen, two views: read-only until "Edit" is tapped, then Full
/// Name/Contact Number become editable in place and Save Changes appears.
/// Replaces the old separate Edit Profile screen/route.
class _ProfileBody extends ConsumerStatefulWidget {
  const _ProfileBody({required this.member});
  final Member member;

  @override
  ConsumerState<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends ConsumerState<_ProfileBody> {
  bool _isEditing = false;
  late final _emailController = TextEditingController(text: widget.member.email);
  late final _nameController = TextEditingController(text: widget.member.fullName);
  late final _phoneController = TextEditingController(text: widget.member.phoneNumber);

  String? _nameError, _phoneError;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Full name is required' : null;
      _phoneError = phone.isEmpty ? 'Contact number is required' : null;
    });
    return _nameError == null && _phoneError == null;
  }

  String _messageFor(Object? error) => error is Failure ? error.message : 'Something went wrong. Please try again.';

  void _startEditing() => setState(() => _isEditing = true);

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final actionState = ref.watch(editProfileControllerProvider);

    ref.listen(editProfileControllerProvider, (previous, next) {
      if (next.value != null && !next.isLoading) {
        setState(() => _isEditing = false);
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(member.initials, style: AppTextStyles.headingLg.copyWith(color: AppColors.textOnPrimary)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _startEditing,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, size: 16, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(label: 'Email', controller: _emailController, enabled: false),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Full Name', style: AppTextStyles.caption),
              if (!_isEditing) TextButton(onPressed: _startEditing, child: const Text('Edit')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(controller: _nameController, enabled: _isEditing, decoration: InputDecoration(errorText: _nameError)),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Contact Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            enabled: _isEditing,
            errorText: _phoneError,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (actionState.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(_messageFor(actionState.error), style: AppTextStyles.bodyMd.copyWith(color: AppColors.danger)),
            ),
          if (_isEditing) ...[
            AppButton(
              label: 'Save Changes',
              isLoading: actionState.isLoading,
              onPressed: actionState.isLoading
                  ? null
                  : () {
                      if (_validate()) {
                        final updated = widget.member.copyWith(
                          fullName: _nameController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                        );
                        ref.read(editProfileControllerProvider.notifier).save(updated);
                      }
                    },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppButton(
            label: 'Log out',
            variant: AppButtonVariant.secondary,
            // No manual navigation needed — the router's own redirect
            // already sends a signed-out user off /home/*.
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
