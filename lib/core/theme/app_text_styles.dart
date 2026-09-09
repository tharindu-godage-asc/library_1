import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Type ramp — Bricolage Grotesque for display/headings (the bold,
/// rounded wordmark style in the mockups), Plus Jakarta Sans for
/// everything read as body text.
class AppTextStyles {
  AppTextStyles._();

  static const _bricolageGrotesque = 'Bricolage Grotesque';
  static const _plusJakartaSans = 'Plus Jakarta Sans';

  static const displayLg = TextStyle(
    fontFamily: _bricolageGrotesque,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const headingLg = TextStyle(
    fontFamily: _bricolageGrotesque,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const headingMd = TextStyle(
    fontFamily: _bricolageGrotesque,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const bodyLg = TextStyle(
    fontFamily: _plusJakartaSans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodyMd = TextStyle(
    fontFamily: _plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const label = TextStyle(
    fontFamily: _plusJakartaSans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontFamily: _plusJakartaSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
