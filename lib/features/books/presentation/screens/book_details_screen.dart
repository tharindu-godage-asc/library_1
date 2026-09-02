import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/datasources/book_mock_datasource.dart';
import '../../domain/repositories/book_repository_impl.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/get_book_by_id.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, required this.bookId});
  final String bookId;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final GetBookById _getBookById = GetBookById(BookRepositoryImpl(BookMockDataSource()));
  Book? _book;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final result = await _getBookById(widget.bookId);
    result.match(
      (failure) => setState(() => _error = 'Could not load this book.'),
      (book) => setState(() => _book = book),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(title: const Text('')),
      body: _error != null
          ? ErrorView(message: _error!, onRetry: _load)
          : _book == null
              ? const LoadingView()
              : _buildContent(_book!),
    );
  }

  Widget _buildContent(Book book) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: 140,
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.asset(
                'assets/images/book cover.jpg',
                width: 140,
                height: 210,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(book.title, style: AppTextStyles.headingMd, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text('${book.author} · ${book.publishedYear}', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.md),
          StatusBadge(status: book.isAvailable ? BadgeStatus.available : BadgeStatus.overdue),
          if (book.description != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(book.description!, style: AppTextStyles.bodyMd, textAlign: TextAlign.center),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: book.isAvailable ? 'Borrow' : 'Currently unavailable',
            onPressed: book.isAvailable
                ? () {
                    // TODO(borrowings): wire to BorrowBook use case once
                    // the Borrowings feature exists. Intentionally a no-op
                    // for now rather than reaching into a feature that
                    // doesn't exist yet.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Borrowing feature coming in a later phase')),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}