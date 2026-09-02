import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/book.dart';

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
    return SizedBox(
      width: 110,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 135,
                color: AppColors.surfaceAlt,
                child: Image.asset(
                  'assets/images/book cover.jpg',
                  width: 120,
                  height: 135,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: AppTextStyles.bodyMd, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(book.author, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
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