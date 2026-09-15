import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/widgets/error_state_view.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirm_sheet.dart';
import '../../../../core/widgets/app_gradient_scaffold.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/book_action_success_snackbar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/domain/entities/auth_session.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../borrowings/domain/entities/borrowing.dart';
import '../../../borrowings/presentation/providers/borrowing_providers.dart';
import '../../domain/entities/book.dart';
import '../providers/book_providers.dart';
import '../widgets/book_cover_image.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  const BookDetailsScreen({super.key, required this.bookId});
  final String bookId;

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  static const double _coverWidth = 140; // must match _buildContent's SizedBox

  String? _coverReadyKey; // book.imageUrl already precached
  String? _precachingKey; // book.imageUrl currently being precached
  bool _justBorrowed = false; // set the instant a borrow succeeds, so the
  // button can't flash back to enabled "Borrow" while myBorrowingsProvider
  // is still refetching or the success sheet is still on screen.

  @override
  Widget build(BuildContext context) {
    final asyncBook = ref.watch(bookByIdProvider(widget.bookId));
    final actionState = ref.watch(borrowActionControllerProvider);
    final session = ref.watch(authControllerProvider).value;
    final myBorrowings = ref.watch(myBorrowingsProvider).value ?? const <Borrowing>[];

    ref.listen(borrowActionControllerProvider, (previous, next) {
      final borrowing = next.value;
      final book = asyncBook.asData?.value;
      if (borrowing != null && book != null) {
        setState(() => _justBorrowed = true);
        unawaited(BookActionSuccessSheet.show(
          context,
          book: book,
          title: book.title,
          heading: 'Book Borrowed!',
          message: '${book.title} is now yours. Bring it back by the\ndue date below.',
          borrowedDate: borrowing.borrowedDate,
          returnDate: borrowing.dueDate,
        ));
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_messageFor(next.error))));
      }
    });

    return AppGradientScaffold(
      appBar: AppBar(title: const Text('')),
      body: asyncBook.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorStateView(
          error: err,
          onRetry: () => ref.invalidate(bookByIdProvider(widget.bookId)),
        ),
        data: (book) {
          _ensureCoverPrecached(book);
          if (book.imageUrl != null && _coverReadyKey != book.imageUrl) {
            return const LoadingView();
          }
          final alreadyBorrowed = _justBorrowed ||
              myBorrowings.any(
                (b) => b.bookId == book.id && b.status != BorrowingStatus.returned,
              );
          return _buildContent(
            context,
            ref,
            book,
            actionState.isLoading,
            session,
            alreadyBorrowed,
          );
        },
      ),
    );
  }

  void _ensureCoverPrecached(Book book) {
    final key = book.imageUrl;
    if (key == null || _coverReadyKey == key || _precachingKey == key) return;
    _precachingKey = key;
    BookCoverImage.precache(context, book, width: _coverWidth).then((_) {
      if (!mounted) return;
      setState(() => _coverReadyKey = key);
    }).catchError((Object error, StackTrace stack) {
      if (!mounted) return;
      _precachingKey = null;
      debugPrint('Failed to precache book cover: $error');
    });
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Book book,
    bool isBorrowing,
    AuthSession? session,
    bool alreadyBorrowed,
  ) {
    final buttonLabel = alreadyBorrowed
        ? 'Already borrowed'
        : book.isAvailable
            ? 'Borrow'
            : 'Currently unavailable';

    return SingleChildScrollView(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(width: _coverWidth, height: 190, child: BookCoverImage(book: book)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            book.title,
            style: AppTextStyles.headingMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${book.author} · ${book.publishedYear}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          StatusBadge(
            status: book.isAvailable
                ? BadgeStatus.available
                : BadgeStatus.overdue,
          ),
          if (book.description != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              book.description!,
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: buttonLabel,
            isLoading: isBorrowing,
            onPressed: book.isAvailable && !isBorrowing && !alreadyBorrowed
                ? () => _confirmAndBorrow(context, ref, book, session)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndBorrow(
    BuildContext context,
    WidgetRef ref,
    Book book,
    AuthSession? session,
  ) async {
    if (session == null) return;
    final dueDate = DateTime.now().add(const Duration(days: 14));
    final confirmed = await AppConfirmSheet.show(
      context,
      title: 'Borrow This Book?',
      message:
          "You'll have 14 days to finish ${book.title} before it's due back on ${formatShortDate(dueDate)}",
      confirmLabel: 'Borrow book',
    );
    if (confirmed == true) {
      ref
          .read(borrowActionControllerProvider.notifier)
          .borrow(bookId: book.id, memberId: session.userId);
    }
  }
}

String _messageFor(Object? error) => error is Failure
    ? error.message
    : 'Something went wrong. Please try again.';
