import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../domain/entities/borrowing.dart';
import '../providers/borrowing_providers.dart';
import '../../../../core/utils/date_formatting.dart';

class MyBorrowingsScreen extends ConsumerWidget {
  const MyBorrowingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBorrowings = ref.watch(myBorrowingsProvider);
    final asyncBooks = ref.watch(bookListProvider);

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('My Borrowings')),
      bottomNavigationBar: AppBottomNavBar(
        items: const [
          AppNavItem(icon: Icons.swap_vert, label: 'Borrowings'),
          AppNavItem(icon: Icons.menu_book_outlined, label: 'Books'),
          AppNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.go('/home');
          if (i == 2) context.go('/home/profile');
        },
      ),
      body: asyncBorrowings.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: 'Could not load your borrowings.',
          onRetry: () => ref.invalidate(myBorrowingsProvider),
        ),
        data: (borrowings) {
          if (borrowings.isEmpty) {
            return const EmptyView(message: "You haven't borrowed any books yet.");
          }
          return asyncBooks.when(
            loading: () => const LoadingView(),
            error: (e, _) => const EmptyView(message: 'Could not load book details.'),
            data: (books) {
              final sorted = [...borrowings]..sort((a, b) => b.borrowedDate.compareTo(a.borrowedDate));
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final borrowing = sorted[i];
                  final book = _findBook(books, borrowing.bookId);
                  return _BorrowingRow(
                    borrowing: borrowing,
                    bookTitle: book?.title ?? 'Unknown book',
                    onTap: () => context.push('/home/borrowings/${borrowing.id}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

Book? _findBook(List<Book> books, String id) {
  for (final b in books) {
    if (b.id == id) return b;
  }
  return null;
}

class _BorrowingRow extends StatelessWidget {
  const _BorrowingRow({required this.borrowing, required this.bookTitle, required this.onTap});
  final Borrowing borrowing;
  final String bookTitle;
  final VoidCallback onTap;

  BadgeStatus get _badgeStatus => switch (borrowing.status) {
        BorrowingStatus.borrowed => BadgeStatus.borrowed,
        BorrowingStatus.returned => BadgeStatus.returned,
        BorrowingStatus.overdue => BadgeStatus.overdue,
      };

String get _subtitle {
  if (borrowing.status == BorrowingStatus.returned) {
    return formatReturnedLabel(borrowing.returnedDate!);
  }
  return 'Due ${formatShortDate(borrowing.dueDate)}';
}

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                    Text(bookTitle, style: AppTextStyles.bodyLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(_subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              StatusBadge(status: _badgeStatus),
            ],
          ),
        ),
      ),
    );
  }
}