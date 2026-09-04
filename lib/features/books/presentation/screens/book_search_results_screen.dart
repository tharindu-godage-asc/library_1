import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';
import 'book_details_screen.dart';

/// Takes the already-loaded book list from BooksScreen rather than
/// re-fetching — avoids a redundant call for data the caller already has.
class BookSearchResultsScreen extends StatefulWidget {
  const BookSearchResultsScreen({super.key, required this.allBooks, required this.initialQuery});
  final List<Book> allBooks;
  final String initialQuery;

  @override
  State<BookSearchResultsScreen> createState() => _BookSearchResultsScreenState();
}

class _BookSearchResultsScreenState extends State<BookSearchResultsScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;

  List<Book> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.allBooks;
    return widget.allBooks
        .where((b) => b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
            child: _results.isEmpty
                ? const EmptyView(message: 'No books match your search.')
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final book = _results[i];
                      return BookCard(
                        book: book,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}