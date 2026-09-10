import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/widgets/error_state_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/illustrated_state_view.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../domain/entities/borrowing.dart';
import '../providers/borrowing_providers.dart';
import '../../../../core/utils/date_formatting.dart';

enum _BorrowingsTab { borrowed, returned }

class MyBorrowingsScreen extends ConsumerStatefulWidget {
  const MyBorrowingsScreen({super.key});

  @override
  ConsumerState<MyBorrowingsScreen> createState() => _MyBorrowingsScreenState();
}

class _MyBorrowingsScreenState extends ConsumerState<MyBorrowingsScreen> {
  _BorrowingsTab _selectedTab = _BorrowingsTab.borrowed;

  @override
  Widget build(BuildContext context) {
    final asyncBorrowings = ref.watch(myBorrowingsProvider);
    final asyncBooks = ref.watch(bookListProvider);

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('My Borrowings')),
      body: asyncBorrowings.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorStateView(
          error: e,
          onRetry: () => ref.invalidate(myBorrowingsProvider),
        ),
        data: (borrowings) {
          if (borrowings.isEmpty) {
            return IllustratedStateView(
              illustrationAsset: 'assets/illustrations/illustration-no-borrowings.png',
              heading: 'No Borrowings Yet',
              message: 'Books you borrow will show up here. Find something good and bring it home.',
              primaryLabel: 'Browse Books',
              onPrimary: () => context.go('/home'),
            );
          }
          return asyncBooks.when(
            loading: () => const LoadingView(),
            error: (e, _) => const Center(
              child: Text('Could not load book details.', style: AppTextStyles.bodyMd),
            ),
            data: (books) {
              final filtered = _filterForTab(borrowings, _selectedTab);
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _BorrowingsTabBar(
                      selected: _selectedTab,
                      onChanged: (tab) => setState(() => _selectedTab = tab),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildTabEmptyState(_selectedTab)
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) {
                                final borrowing = filtered[i];
                                final book = _findBook(books, borrowing.bookId);
                                return _BorrowingRow(
                                  borrowing: borrowing,
                                  bookTitle: book?.title ?? 'Unknown book',
                                  onTap: () => context.push('/home/borrowings/${borrowing.id}'),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Borrowing> _filterForTab(List<Borrowing> borrowings, _BorrowingsTab tab) {
    return switch (tab) {
      _BorrowingsTab.borrowed => [...borrowings.where((b) => b.status != BorrowingStatus.returned)]
        ..sort((a, b) => b.borrowedDate.compareTo(a.borrowedDate)),
      _BorrowingsTab.returned => [...borrowings.where((b) => b.status == BorrowingStatus.returned)]
        ..sort((a, b) => b.returnedDate!.compareTo(a.returnedDate!)),
    };
  }

  Widget _buildTabEmptyState(_BorrowingsTab tab) {
    return switch (tab) {
      _BorrowingsTab.borrowed => const IllustratedStateView(
          illustrationAsset: 'assets/illustrations/illustration-no-borrowings.png',
          heading: 'No Borrowings Yet',
          message: 'Books you borrow will show up here. Find something good and bring it home.',
        ),
      _BorrowingsTab.returned => const IllustratedStateView(
          illustrationAsset: 'assets/illustrations/illustration-no-borrowings.png',
          heading: 'No Returned Books Yet',
          message: "Books you return will show up here once you bring them back.",
        ),
    };
  }
}

Book? _findBook(List<Book> books, String id) {
  for (final b in books) {
    if (b.id == id) return b;
  }
  return null;
}

class _BorrowingsTabBar extends StatelessWidget {
  const _BorrowingsTabBar({required this.selected, required this.onChanged});
  final _BorrowingsTab selected;
  final ValueChanged<_BorrowingsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabSegment(
              label: 'Borrowed',
              selected: selected == _BorrowingsTab.borrowed,
              onTap: () => onChanged(_BorrowingsTab.borrowed),
            ),
          ),
          Expanded(
            child: _TabSegment(
              label: 'Returned',
              selected: selected == _BorrowingsTab.returned,
              onTap: () => onChanged(_BorrowingsTab.returned),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
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
