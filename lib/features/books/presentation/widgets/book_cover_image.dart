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
///
/// Callers that want to avoid that placeholder→fade-in pop on first paint
/// (e.g. a screen that wants to reveal its whole layout only once the cover
/// is ready) can call [precache] ahead of building this widget.
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
              final optimizedUrl = targetWidthPx == null ? url : sizedUrl(url, targetWidthPx);
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
  static String sizedUrl(String url, int targetWidthPx) {
    final size = targetWidthPx <= 120 ? 'S' : targetWidthPx <= 320 ? 'M' : 'L';
    return url.replaceFirst(RegExp(r'-[SML]\.jpg$'), '-$size.jpg');
  }

  /// Loads this book's cover into Flutter's [ImageCache] ahead of time, at
  /// the exact same [ResizeImage]/[NetworkImage] the [build] method above
  /// would request for a box of the given [width] — so that once this
  /// widget actually builds, `Image.network` resolves synchronously
  /// (`wasSynchronouslyLoaded: true`) instead of showing the placeholder
  /// and fading the real cover in.
  ///
  /// No-ops immediately if [Book.imageUrl] is null. Never throws or hangs
  /// indefinitely: a failed or slow request is bounded by [timeout] and
  /// falls back to the placeholder/error handling already built into
  /// [build] once this widget is actually shown.
  static Future<void> precache(
    BuildContext context,
    Book book, {
    required double width,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final url = book.imageUrl;
    if (url == null) return;
    final targetWidthPx = (width * MediaQuery.devicePixelRatioOf(context)).round();
    if (targetWidthPx <= 0) return;
    final provider = ResizeImage.resizeIfNeeded(
      targetWidthPx,
      null,
      NetworkImage(sizedUrl(url, targetWidthPx)),
    );
    try {
      await precacheImage(provider, context, onError: (_, _) {}).timeout(timeout, onTimeout: () {});
    } catch (_) {
      // Best-effort — this widget's own placeholder/error handling takes
      // over if the image never loads.
    }
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
