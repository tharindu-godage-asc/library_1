import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/widgets/error_state_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../domain/entities/borrowing.dart';
import '../providers/borrowing_providers.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/widgets/app_confirm_sheet.dart';
import '../../../../core/widgets/book_action_success_snackbar.dart';

class BorrowingDetailsScreen extends ConsumerWidget {
  const BorrowingDetailsScreen({super.key, required this.borrowingId});
  final String borrowingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBorrowing = ref.watch(borrowingByIdProvider(borrowingId));
    final returnState = ref.watch(returnActionControllerProvider);

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Borrowing Details')),
      body: asyncBorrowing.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(
          error: e,
          onRetry: () => ref.invalidate(borrowingByIdProvider(borrowingId)),
        ),
        data: (borrowing) {
          final asyncBook = ref.watch(bookByIdProvider(borrowing.bookId));
          return asyncBook.when(
            loading: () => const LoadingView(),
            error: (e, _) => const Center(
              child: Text('Could not load book details.', style: AppTextStyles.bodyMd),
            ),
            data: (book) {
              ref.listen(returnActionControllerProvider, (previous, next) {
                if (next.value != null && next.value!.id == borrowingId && !next.isLoading) {
                  final returnedBorrowing = next.value!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: BookActionSuccessSnackBar(
                        title: book.title,
                        heading: 'Book Returned!',
                        message: 'Thanks for returning ${book.title}.\nIt\'s back on the shelf for the next reader.',
                        dateLabel: returnedBorrowing.returnedDate == null
                            ? 'Returned today'
                            : formatReturnedLabel(returnedBorrowing.returnedDate!),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.fromLTRB(11, 0, 11, 0),
                      duration: const Duration(seconds: 6),
                    ),
                  );
                }
              });
              return _buildContent(context, ref, borrowing, book, returnState);
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Borrowing borrowing,
    Book book,
    AsyncValue<Borrowing?> returnState,
  ) {
    final badgeStatus = switch (borrowing.status) {
      BorrowingStatus.borrowed => BadgeStatus.borrowed,
      BorrowingStatus.returned => BadgeStatus.returned,
      BorrowingStatus.overdue => BadgeStatus.overdue,
    };

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 60,
                      decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title, style: AppTextStyles.bodyLg),
                          Text(
                            borrowing.status == BorrowingStatus.returned
                                ? formatReturnedLabel(borrowing.returnedDate!)
                                : 'Due ${formatShortDate(borrowing.dueDate)}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: badgeStatus),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (borrowing.status != BorrowingStatus.returned) ...[
              if (returnState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(_messageFor(returnState.error), style: AppTextStyles.bodyMd.copyWith(color: AppColors.danger)),
                ),
              AppButton(
                label: 'Return this book',
                isLoading: returnState.isLoading,
                onPressed: returnState.isLoading ? null : () => _confirmAndReturn(context, ref, borrowing),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndReturn(BuildContext context, WidgetRef ref, Borrowing borrowing) async {
    final confirmed = await AppConfirmSheet.show(
      context,
      title: 'Return This Book?',
      message: "You're about to mark this book as returned. This can't be undone.",
      confirmLabel: 'Return book',
    );
    if (confirmed == true) {
      ref.read(returnActionControllerProvider.notifier).returnBook(borrowing.id, borrowing.bookId);
    }
  }
}

String _messageFor(Object? error) => error is Failure ? error.message : 'Something went wrong. Please try again.';
