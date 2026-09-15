import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/books/domain/entities/book.dart';
import '../../features/books/presentation/widgets/book_cover_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';
import '../utils/date_formatting.dart';

class BookActionSuccessSheet {
  const BookActionSuccessSheet._();

  /// Precaches the book's cover (at the size [BookActionSuccessSnackBar]
  /// actually displays it) before opening the sheet, so the cover doesn't
  /// pop in over the placeholder once the sheet is already visible.
  static Future<void> show(
    BuildContext context, {
    required Book book,
    required String title,
    required String heading,
    required String message,
    required DateTime borrowedDate,
    required DateTime returnDate,
  }) async {
    final (width, _) = _coverBoxSize(context);
    await BookCoverImage.precache(
      context,
      book,
      width: width,
      timeout: const Duration(seconds: 2),
    );
    if (!context.mounted) return;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AutoDismiss(
        child: BookActionSuccessSnackBar(
          book: book,
          title: title,
          heading: heading,
          message: message,
          borrowedDate: borrowedDate,
          returnDate: returnDate,
        ),
      ),
    );
  }
}

/// Shared cover-box sizing for the sheet's cover image, used both when
/// deciding what to [BookCoverImage.precache] and by
/// [BookActionSuccessSnackBar] when it actually renders the cover, so the
/// two can never drift apart.
(double width, double height) _coverBoxSize(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height * 0.25;
  return (height * 38 / 52, height);
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
    required this.book,
    required this.title,
    required this.heading,
    required this.message,
    required this.borrowedDate,
    required this.returnDate,
  });

  final Book book;
  final String title;
  final String heading;
  final String message;
  final DateTime borrowedDate;
  final DateTime returnDate;

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.6;
    final (coverWidth, coverHeight) = _coverBoxSize(context);
    return Stack(
      children: [
        SizedBox(
          height: sheetHeight,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            padding: EdgeInsets.fromLTRB(18, 12, 18, 14 + MediaQuery.paddingOf(context).bottom),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/illustrations/illustration-onboarding-borrow.png',
                      height: 88,
                      fit: BoxFit.contain,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: SizedBox(
                              width: coverWidth,
                              height: coverHeight,
                              child: BookCoverImage(book: book),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: AppTextStyles.label),
                                const SizedBox(height: 4),
                                Text(
                                  'Borrowed Date: ${formatShortDate(borrowedDate)}',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Return Date: ${formatShortDate(returnDate)}',
                                  style: AppTextStyles.caption,
                                ),
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
                        onPressed: () {
                          final router = GoRouter.of(context);
                          Navigator.of(context).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            router.go('/home');
                          });
                        },
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
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 22),
            tooltip: 'Close',
          ),
        ),
      ],
    );
  }
}
