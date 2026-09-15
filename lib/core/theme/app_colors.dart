import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background gradient (used behind most screens)
  static const backgroundTop = Color(0xFFF3E6D5);
  static const backgroundBottom = Color(0xFFEAE0EE);

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1E3C8); // e.g. "Log out" button bg

  // Text
  static const textPrimary = Color(0xFF2B2420);
  static const textSecondary = Color(0xFF8B8681);
  static const textOnPrimary = Color(0xFF2B2420); // dark text sits on the gold buttons

  // Brand / action
  static const primary = Color(0xFFE8B84B);
  static const primaryPressed = Color(0xFFC89530);

  // Status (borrowing states)
  static const success = Color(0xFF2F9E64);
  static const successBg = Color(0xFFDCEFE3);
  static const warning = Color(0xFF8A6A2E); // "Borrowed"
  static const warningBg = Color(0xFFF1DFC0);
  static const danger = Color(0xFFD0566B); // "Overdue"
  static const dangerBg = Color(0xFFF7DADD);

  static const border = Color(0xFFE4D9CB);
}