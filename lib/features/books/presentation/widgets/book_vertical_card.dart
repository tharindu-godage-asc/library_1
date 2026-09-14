import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/book.dart';

/// A book cover + title/author card used in the Books screen's horizontal
/// shelves.
///
/// Sizes itself from [AppDimens.bookCardWidth] and its own content height
/// (no fixed outer height) so text is never clipped at larger system font
/// scales, and the card scales between phone and tablet/landscape widths.
class BookVerticalCard extends StatelessWidget {
  const BookVerticalCard({
    super.key,
    required this.book,
    required this.onTap,
    this.dueInDays,
  });

  final Book book;
  final VoidCallback onTap;
  final int? dueInDays;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    // Reserved regardless of actual line count, so a short title/author
    // doesn't leave this card shorter than a sibling card in the same
    // shelf whose title wraps to the full 2 lines.
    final titleHeight = AppDimens.lineHeight(AppTextStyles.bodyMd, textScaler) * 2;
    final authorHeight = AppDimens.lineHeight(AppTextStyles.caption, textScaler);

    return SizedBox(
      width: AppDimens.bookCardWidth(context),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: AppDimens.bookCoverAspectRatio,
                child: Container(
                  color: AppColors.surfaceAlt,
                  child: const Icon(Icons.menu_book_outlined, color: AppColors.textSecondary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: titleHeight,
                      child: Text(book.title, style: AppTextStyles.bodyMd, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(
                      height: authorHeight,
                      child: Text(book.author, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (dueInDays != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('Due in $dueInDays days', style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
