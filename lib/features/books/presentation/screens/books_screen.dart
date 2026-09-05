import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/book.dart';
import '../providers/book_providers.dart';
import '../widgets/book_card.dart';
import '../widgets/book_vertical_card.dart';
import '../widgets/reminder_banner.dart';
import 'book_details_screen.dart';
import 'book_search_results_screen.dart';

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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: id)));
  }

  void _openSearchResults() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BookSearchResultsScreen(initialQuery: _query),
    ));
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
      bottomNavigationBar: AppBottomNavBar(
        items: const [
          AppNavItem(icon: Icons.swap_vert, label: 'Borrowings'),
          AppNavItem(icon: Icons.menu_book_outlined, label: 'Books'),
          AppNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
        currentIndex: 1,
        onTap: (i) {
          if (i != 1) _todo(['Borrowings', 'Books', 'Profile'][i]);
        },
      ),
      body: asyncBooks.when(
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          message: 'Could not load books. Please try again.',
          onRetry: () => ref.invalidate(bookListProvider),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(List<Book> books) {
    final matches = _searchMatches(books);
    final borrowedPreview = _borrowedPreview(books);
    final soonestDue = _soonestDue(borrowedPreview);
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
                    // TODO(auth): replace with the signed-in member's name
                    // once the Auth feature provides a session.
                    Text('Amaya Perera', style: AppTextStyles.headingLg),
                  ],
                ),
                GestureDetector(
                  onTap: () => _todo('Notifications'),
                  child: Container(
                    width: 44,
                    height: 44,
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
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
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
                bookTitle: soonestDue.book.title,
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
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
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

  // ---- TEMPORARY mock content (same as before, untouched) ----------------
  List<_BorrowedPreview> _borrowedPreview(List<Book> books) {
    if (books.length < 3) return [];
    const dueDays = [2, 2, 1];
    return List.generate(3, (i) => _BorrowedPreview(book: books[i], dueInDays: dueDays[i]));
  }

  _BorrowedPreview? _soonestDue(List<_BorrowedPreview> preview) {
    if (preview.isEmpty) return null;
    return preview.reduce((a, b) => a.dueInDays <= b.dueInDays ? a : b);
  }

  List<Book> _newestPicks(List<Book> books) {
    final sorted = [...books]..sort((a, b) => b.publishedYear.compareTo(a.publishedYear));
    return sorted.take(10).toList();
  }
}

class _BorrowedPreview {
  const _BorrowedPreview({required this.book, required this.dueInDays});
  final Book book;
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