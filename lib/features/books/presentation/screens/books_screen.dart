import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/widgets/error_state_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/book.dart';
import '../providers/book_providers.dart';
import '../widgets/book_card.dart';
import '../widgets/book_vertical_card.dart';
import '../widgets/reminder_banner.dart';
import '../../../borrowings/domain/entities/borrowing.dart';
import '../../../borrowings/presentation/providers/borrowing_providers.dart';
import '../../../members/presentation/providers/member_providers.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  // Search text is screen-local UI state — nothing else in the app needs
  // to observe it, so it stays plain State instead of becoming a
  // provider. Contrast with the book list below, which is genuinely app
  // state (fetched, worth caching, shared across screens) and lives in
  // bookListProvider instead. Not everything needs to go through Riverpod.
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _searchMatches(List<Book> books) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return books.where((b) => b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q)).toList();
  }

  void _openBook(String id) {
    context.push('/home/book/$id');
  }

  void _openSearchResults() {
    context.push(Uri(path: '/home/search', queryParameters: {'q': _query}).toString());
  }

  void _todo(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming in a later phase')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncBooks = ref.watch(bookListProvider);

    return AppGradientScaffold(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      body: asyncBooks.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorStateView(
          error: err,
          onRetry: () => ref.invalidate(bookListProvider),
        ),
        data: (books) {
          final asyncBorrowings = ref.watch(myBorrowingsProvider);
          // Fails soft: Books doesn't block on borrowings loading — the
          // Reminder banner just doesn't show yet/at all if this is slow
          // or errors. A deliberate simplification, not a general pattern
          // for every cross-feature dependency.
          return asyncBorrowings.when(
            loading: () => _buildContent(books, const []),
            error: (_, _) => _buildContent(books, const []),
            data: (borrowings) => _buildContent(books, borrowings),
          );
        },
      ),
    );
  }

  Widget _buildContent(List<Book> books, List<Borrowing> myBorrowings) {
    final asyncProfile = ref.watch(myProfileProvider);
    final matches = _searchMatches(books);
    final soonestDue = _soonestDueReminder(myBorrowings, books);
    final recommended = books.reversed.take(10).toList();
    final newestPicks = _newestPicks(books);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Evening', style: AppTextStyles.bodyMd),
                    Text(asyncProfile.value?.fullName ?? '', style: AppTextStyles.headingLg),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/home/notifications'),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: AppColors.surfaceAlt, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppSearchField(
              controller: _searchController,
              hintText: 'Search books...',
              onChanged: (v) => setState(() => _query = v),
            ),
            if (_query.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ...matches.take(3).map(
                    (book) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: BookCard(book: book, onTap: () => _openBook(book.id)),
                    ),
                  ),
              if (matches.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('No books match your search.', style: AppTextStyles.bodyMd),
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: _openSearchResults, child: const Text('See All')),
                ),
            ],
            if (newestPicks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Newest Picks', onSeeAll: () => _todo('Newest Picks')),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: newestPicks.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final book = newestPicks[i];
                    return BookVerticalCard(book: book, onTap: () => _openBook(book.id));
                  },
                ),
              ),
            ],
            if (soonestDue != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ReminderBanner(
                bookTitle: soonestDue.bookTitle,
                dueInDays: soonestDue.dueInDays,
                onRenew: () => _todo('Renew'),
              ),
            ],
            if (recommended.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _SectionHeader(title: 'Recommended for You', onSeeAll: () => _todo('Recommendations')),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, i) => BookVerticalCard(
                    book: recommended[i],
                    onTap: () => _openBook(recommended[i].id),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _DueSoon? _soonestDueReminder(List<Borrowing> borrowings, List<Book> books) {
    final candidates = borrowings.where((b) => b.status == BorrowingStatus.borrowed);
    if (candidates.isEmpty) return null;
    final soonest = candidates.reduce((a, b) => a.dueDate.isBefore(b.dueDate) ? a : b);
    final daysLeft = soonest.dueDate.difference(DateTime.now()).inDays;
    if (daysLeft > 3) return null; // only surface the reminder when it's actually close
    final book = _findBook(books, soonest.bookId);
    return _DueSoon(bookTitle: book?.title ?? 'A book', dueInDays: daysLeft);
  }

  Book? _findBook(List<Book> books, String id) {
    for (final b in books) {
      if (b.id == id) return b;
    }
    return null;
  }

  List<Book> _newestPicks(List<Book> books) {
    final sorted = [...books]..sort((a, b) => b.publishedYear.compareTo(a.publishedYear));
    return sorted.take(10).toList();
  }
}

class _DueSoon {
  const _DueSoon({required this.bookTitle, required this.dueInDays});
  final String bookTitle;
  final int dueInDays;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headingMd),
        GestureDetector(
          onTap: onSeeAll,
          child: Text('See all', style: AppTextStyles.bodyMd.copyWith(color: AppColors.primaryPressed)),
        ),
      ],
    );
  }
}