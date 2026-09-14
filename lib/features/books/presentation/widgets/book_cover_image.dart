import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/book.dart';

/// Renders a book's cover image, filling whatever box it's placed in via
/// [BoxFit.cover] — so every cover ends up the same visual size as its
/// container regardless of the source image's actual resolution or aspect
/// ratio. Shows a placeholder icon underneath at all times, and — once
/// there's an [Book.imageUrl] — cross-fades the real image in over it as
/// soon as it decodes, rather than popping in abruptly. Loading, missing,
/// and failed images all just leave the placeholder showing.
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final url = book.imageUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        const _CoverPlaceholder(),
        if (url != null)
          LayoutBuilder(
            builder: (context, constraints) {
              final targetWidthPx = constraints.maxWidth.isFinite
                  ? (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context)).round()
                  : null;
              final optimizedUrl = targetWidthPx == null ? url : _sizedUrl(url, targetWidthPx);
              return Image.network(
                optimizedUrl,
                fit: BoxFit.cover,
                cacheWidth: targetWidthPx,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              );
            },
          ),
      ],
    );
  }

  /// Open Library only serves a few fixed cover sizes (S/M/L). Requesting
  /// the smallest one that's still >= the actual on-screen pixel width
  /// avoids downloading and decoding a much larger image than will ever be
  /// displayed — the 44x60 borrowing-row thumbnail doesn't need the same
  /// file as the 140x190 detail-screen cover.
  static String _sizedUrl(String url, int targetWidthPx) {
    final size = targetWidthPx <= 120 ? 'S' : targetWidthPx <= 320 ? 'M' : 'L';
    return url.replaceFirst(RegExp(r'-[SML]\.jpg$'), '-$size.jpg');
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_outlined, color: AppColors.textSecondary),
    );
  }
}
