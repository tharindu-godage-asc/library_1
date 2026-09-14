import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/book.dart';
import 'book_vertical_card.dart';

/// A horizontally scrolling shelf of [BookVerticalCard]s.
///
/// Uses a [Row] inside a horizontal [SingleChildScrollView] rather than a
/// [ListView] so the shelf's height comes from its tallest card instead of
/// a fixed pixel value — this is what avoids the clipping a hard-coded
/// SizedBox height causes at larger text scales. Shelves here are small
/// (<=10 items), so giving up ListView's lazy building/recycling is an
/// acceptable trade for a shelf that never crops.
///
/// [BookShelf] is meant to be placed directly in a screen's content with no
/// horizontal padding around it, so its scroll viewport can span the true
/// screen edge instead of clipping the peeking card early against an
/// ancestor's padding. Pass [edgeInset] (matching the screen's own content
/// margin) to keep cards visually aligned with the rest of the padded
/// screen at rest, while still letting the shelf scroll edge-to-edge.
class BookShelf extends StatelessWidget {
  const BookShelf({super.key, required this.books, required this.onTapBook, this.edgeInset = 0});

  final List<Book> books;
  final ValueChanged<Book> onTapBook;
  final double edgeInset;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: edgeInset),
          for (var i = 0; i < books.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            BookVerticalCard(book: books[i], onTap: () => onTapBook(books[i])),
          ],
          SizedBox(width: edgeInset),
        ],
      ),
    );
  }
}
