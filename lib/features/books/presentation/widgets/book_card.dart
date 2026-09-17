import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/book.dart';
import 'book_cover_image.dart';

class BookCard extends StatelessWidget {
  const BookCard({super.key, required this.book, required this.onTap});
  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      // Shape/color/elevation come from AppTheme.light.cardTheme.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(width: 44, height: 60, child: BookCoverImage(book: book)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: AppTextStyles.bodyLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(book.author, style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    StatusBadge(status: book.isAvailable ? BadgeStatus.available : BadgeStatus.borrowed),
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