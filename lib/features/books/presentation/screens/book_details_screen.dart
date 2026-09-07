import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/book.dart';
import '../providers/book_providers.dart';

class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBook = ref.watch(bookByIdProvider(bookId));

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('')),
      body: asyncBook.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          message: 'Could not load this book.',
          onRetry: () => ref.invalidate(bookByIdProvider(bookId)),
        ),
        data: (book) => _buildContent(context, book),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Book book) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 140,
            height: 190,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(book.title, style: AppTextStyles.headingMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text('${book.author} · ${book.publishedYear}', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.md),
          StatusBadge(status: book.isAvailable ? BadgeStatus.available : BadgeStatus.overdue),
          if (book.description != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(book.description!, style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: book.isAvailable ? 'Borrow' : 'Currently unavailable',
            onPressed: book.isAvailable
                ? () {
                    // // TODO(borrowings): wire to BorrowBook use case once
                    // the Borrowings feature exists.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Borrowing feature coming in a later phase')),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}