import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_sheet.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../borrowings/presentation/providers/borrowing_providers.dart';
import '../../domain/entities/book.dart';
import '../providers/book_providers.dart';

class BookDetailsScreen extends ConsumerWidget {
  const BookDetailsScreen({super.key, required this.bookId});
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBook = ref.watch(bookByIdProvider(bookId));
    final actionState = ref.watch(borrowActionControllerProvider);
    final session = ref.watch(authControllerProvider).value;

    ref.listen(borrowActionControllerProvider, (previous, next) {
      final borrowing = next.value;
      if (borrowing != null) {
        context.go('/home/borrowings/${borrowing.id}?justBorrowed=true');
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_messageFor(next.error))),
        );
      }
    });

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('')),
      body: asyncBook.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          message: 'Could not load this book.',
          onRetry: () => ref.invalidate(bookByIdProvider(bookId)),
        ),
        data: (book) => _buildContent(context, ref, book, actionState.isLoading, session),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Book book,
    bool isBorrowing,
    AuthSession? session,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 140,
            height: 190,
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.md)),
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
            isLoading: isBorrowing,
            onPressed: book.isAvailable && !isBorrowing
                ? () => _confirmAndBorrow(context, ref, book, session)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndBorrow(
    BuildContext context,
    WidgetRef ref,
    Book book,
    AuthSession? session,
  ) async {
    if (session == null) return;
    final dueDate = DateTime.now().add(const Duration(days: 14));
    final confirmed = await AppConfirmSheet.show(
      context,
      title: 'Borrow This Book?',
      message: "You'll have 14 days to finish ${book.title} before it's due back on ${formatShortDate(dueDate)}",
      confirmLabel: 'Borrow book',
    );
    if (confirmed == true) {
      ref.read(borrowActionControllerProvider.notifier).borrow(bookId: book.id, memberId: session.userId);
    }
  }
}

String _messageFor(Object? error) => error is Failure ? error.message : 'Something went wrong. Please try again.';