import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class BookActionSuccessSheet {
  const BookActionSuccessSheet._();

  static void show(
    BuildContext context, {
    required String title,
    required String heading,
    required String message,
    required String dateLabel,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AutoDismiss(
        child: BookActionSuccessSnackBar(
          title: title,
          heading: heading,
          message: message,
          dateLabel: dateLabel,
        ),
      ),
    );
  }
}

class _AutoDismiss extends StatefulWidget {
  const _AutoDismiss({required this.child});
  final Widget child;

  @override
  State<_AutoDismiss> createState() => _AutoDismissState();
}

class _AutoDismissState extends State<_AutoDismiss> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class BookActionSuccessSnackBar extends StatelessWidget {
  const BookActionSuccessSnackBar({
    super.key,
    required this.title,
    required this.heading,
    required this.message,
    required this.dateLabel,
  });

  final String title;
  final String heading;
  final String message;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      padding: EdgeInsets.fromLTRB(18, 12, 18, 14 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 92,
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/illustrations/illustration-onboarding-borrow.png',
                    height: 88,
                    fit: BoxFit.contain,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 22),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(heading, style: AppTextStyles.headingMd.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Container(
            height: 68,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/images/book cover.jpg',
                    width: 38,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 2),
                      Text(dateLabel, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                textStyle: AppTextStyles.label,
              ),
              child: const Text('Back to Books'),
            ),
          ),
        ],
      ),
    );
  }
}
