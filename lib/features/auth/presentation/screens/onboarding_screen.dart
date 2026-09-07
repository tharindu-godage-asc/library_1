import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/auth_gate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_providers.dart';

class _OnboardingSlideData {
  const _OnboardingSlideData({required this.title, required this.illustration});
  final String title;
  final Widget illustration;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlideData> _slides = [
    _OnboardingSlideData(
      title: 'Discover your Next\nFavourite Book',
      illustration: Image.asset('assets/illustrations/illustration-onboarding-discover.png', fit: BoxFit.contain),
    ),
    _OnboardingSlideData(
      title: 'Borrow with a Tap',
      illustration: Image.asset('assets/illustrations/illustration-onboarding-borrow.png', fit: BoxFit.contain),
    ),
    _OnboardingSlideData(
      title: 'Get Reminders on Time',
      illustration: Image.asset('assets/illustrations/illustration-onboarding-milestones.png', fit: BoxFit.contain),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _slides.length - 1;

  // Single source of truth — this is the ONLY _finish() now. It must mark
  // onboarding complete before navigating, or appBootstrapProvider will
  // send the user right back to onboarding on the next cold start,
  // silently undoing the whole point of this slice.
  Future<void> _finish() async {
    await ref.read(onboardingPreferenceProvider).markCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _back() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, i) => _SlideContent(slide: _slides[i]),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.lg,
                    child: TextButton(
                      onPressed: _finish,
                      child: Text('Skip', style: AppTextStyles.label.copyWith(color: AppColors.primaryPressed)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.backgroundBottom,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavIconButton(
                    icon: Icons.chevron_left,
                    onPressed: _currentPage == 0 ? null : _back,
                    visible: _currentPage != 0,
                  ),
                  _DotIndicator(count: _slides.length, activeIndex: _currentPage),
                  _NavIconButton(icon: Icons.chevron_right, onPressed: _next, visible: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide});
  final _OnboardingSlideData slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(child: slide.illustration),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            color: AppColors.backgroundBottom,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: Text(slide.title, style: AppTextStyles.headingLg),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.activeIndex});
  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, required this.onPressed, required this.visible});
  final IconData icon;
  final VoidCallback? onPressed;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(width: 40, height: 40);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.textPrimary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }
}