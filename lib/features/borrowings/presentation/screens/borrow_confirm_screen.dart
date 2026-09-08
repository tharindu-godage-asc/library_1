import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../providers/borrowing_providers.dart';

class BorrowConfirmScreen extends ConsumerWidget {
  const BorrowConfirmScreen({super.key, required this.bookId});
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
    });

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Confirm Borrowing')),
      body: asyncBook.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: 'Could not load this book.',
          onRetry: () => ref.invalidate(bookByIdProvider(bookId)),
        ),
        data: (book) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.title, style: AppTextStyles.headingMd),
              Text(book.author, style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Borrowing starts today and is due back in 14 days. '
                'Make sure to return it on time to avoid overdue status.',
                style: AppTextStyles.bodyMd,
              ),
              const Spacer(),
              if (actionState.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(_messageFor(actionState.error), style: AppTextStyles.bodyMd.copyWith(color: AppColors.danger)),
                ),
              AppButton(
                label: 'Confirm Borrow',
                isLoading: actionState.isLoading,
                onPressed: session == null || actionState.isLoading
                    ? null
                    : () => ref
                        .read(borrowActionControllerProvider.notifier)
                        .borrow(bookId: bookId, memberId: session.userId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _messageFor(Object? error) => error is Failure ? error.message : 'Something went wrong. Please try again.';