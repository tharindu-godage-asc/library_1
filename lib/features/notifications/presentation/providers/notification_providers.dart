import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/date_formatting.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/presentation/providers/book_providers.dart';
import '../../../borrowings/domain/entities/borrowing.dart';
import '../../../borrowings/presentation/providers/borrowing_providers.dart';

part 'notification_providers.g.dart';

enum NotificationTone { dueSoon, overdue, info }

class NotificationItem {
  const NotificationItem({required this.tone, required this.title, required this.action, required this.timeLabel});
  final NotificationTone tone;
  final String title;
  final String action;
  final String timeLabel;
}

/// Reshapes existing Borrowings + Books data into notification-style
/// rows. If a real notifications endpoint ever exists (Phase 18+), this
/// file is what changes — the screen below wouldn't need to.
@riverpod
Future<List<NotificationItem>> notificationItems(Ref ref) async {
  final borrowings = await ref.watch(myBorrowingsProvider.future);
  final books = await ref.watch(bookListProvider.future);
  final now = DateTime.now();

  Book? findBook(String id) {
    for (final b in books) {
      if (b.id == id) return b;
    }
    return null;
  }

  final items = <NotificationItem>[];
  for (final b in borrowings) {
    final title = findBook(b.bookId)?.title ?? 'A book';

    if (b.status == BorrowingStatus.overdue) {
      final daysOverdue = now.difference(b.dueDate).inDays;
      items.add(NotificationItem(
        tone: NotificationTone.overdue,
        title: title,
        action: 'Overdue — please return as soon as possible',
        timeLabel: '$daysOverdue day${daysOverdue == 1 ? '' : 's'} overdue',
      ));
    } else if (b.status == BorrowingStatus.borrowed) {
      final daysLeft = b.dueDate.difference(now).inDays;
      if (daysLeft <= 3) {
        items.add(NotificationItem(
          tone: NotificationTone.dueSoon,
          title: title,
          action: daysLeft <= 0 ? 'Due today' : 'Due in $daysLeft day${daysLeft == 1 ? '' : 's'}',
          timeLabel: formatShortDate(b.dueDate),
        ));
      }
    } else if (b.status == BorrowingStatus.returned && b.returnedDate != null) {
      final daysAgo = now.difference(b.returnedDate!).inDays;
      if (daysAgo <= 7) {
        items.add(NotificationItem(
          tone: NotificationTone.info,
          title: title,
          action: 'Returned successfully',
          timeLabel: formatReturnedLabel(b.returnedDate!),
        ));
      }
    }
  }
  return items;
}