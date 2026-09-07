import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/book.dart';
import '../providers/book_providers.dart';
import '../widgets/book_card.dart';
import 'book_details_screen.dart';

/// No longer takes the book list as a constructor param. It watches
/// bookListProvider directly — since it caches its result, this
/// reuses the exact same fetch BooksScreen already triggered instead of
/// re-fetching, without threading data through navigation to get there.
class BookSearchResultsScreen extends ConsumerStatefulWidget {
  const BookSearchResultsScreen({super.key, required this.initialQuery});
  final String initialQuery;

  @override
  ConsumerState<BookSearchResultsScreen> createState() => _BookSearchResultsScreenState();
}

class _BookSearchResultsScreenState extends ConsumerState<BookSearchResultsScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  List<Book> _results(List<Book> allBooks) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return allBooks;
    return allBooks
        .where((b) => b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncBooks = ref.watch(bookListProvider);

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchField(
            controller: _controller,
            hintText: 'Search books...',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: asyncBooks.when(
              loading: () => const LoadingView(),
              error: (err, stack) => ErrorView(
                message: 'Could not load books.',
                onRetry: () => ref.invalidate(bookListProvider),
              ),
              data: (allBooks) {
                final results = _results(allBooks);
                if (results.isEmpty) {
                  return const EmptyView(message: 'No books match your search.');
                }
                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final book = results[i];
                    return BookCard(
                      book: book,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}