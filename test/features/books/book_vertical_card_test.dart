import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_1/core/theme/app_dimens.dart';
import 'package:library_1/features/books/domain/entities/book.dart';
import 'package:library_1/features/books/presentation/widgets/book_vertical_card.dart';

void main() {
  final longTitleBook = Book.empty().copyWith(
    id: '1',
    title: 'A Very Long Book Title That Should Wrap Across Multiple Lines Of Text',
    author: 'An Extremely Long Author Name For Layout Testing Purposes',
  );

  final shortTitleBook = Book.empty().copyWith(
    id: '2',
    title: 'Clean Code',
    author: 'Robert C. Martin',
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    required Size size,
    double textScale = 1.0,
    int? dueInDays,
    Book? book,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size, textScaler: TextScaler.linear(textScale)),
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: BookVerticalCard(book: book ?? longTitleBook, onTap: () {}, dueInDays: dueInDays),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders without overflow on a narrow phone at default text scale', (tester) async {
    await pumpCard(tester, size: const Size(320, 640));

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a tablet at default text scale', (tester) async {
    await pumpCard(tester, size: const Size(1024, 1366));

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow at a large accessibility text scale, with a due date row', (tester) async {
    await pumpCard(tester, size: const Size(360, 800), textScale: 1.5, dueInDays: 3);

    expect(tester.takeException(), isNull);
  });

  testWidgets('card width scales between phone and tablet within the configured bounds', (tester) async {
    await pumpCard(tester, size: const Size(320, 640));
    final phoneWidth = tester.getSize(find.byType(BookVerticalCard)).width;

    await pumpCard(tester, size: const Size(1024, 1366));
    final tabletWidth = tester.getSize(find.byType(BookVerticalCard)).width;

    expect(phoneWidth, greaterThanOrEqualTo(AppDimens.bookCardMinWidth));
    expect(tabletWidth, lessThanOrEqualTo(AppDimens.bookCardMaxWidth));
    expect(tabletWidth, greaterThan(phoneWidth));
  });

  testWidgets('card height is the same whether the title wraps to 1 line or 2 lines', (tester) async {
    const size = Size(360, 800);

    await pumpCard(tester, size: size, book: shortTitleBook);
    final shortTitleCardHeight = tester.getSize(find.byType(BookVerticalCard)).height;

    await pumpCard(tester, size: size, book: longTitleBook);
    final longTitleCardHeight = tester.getSize(find.byType(BookVerticalCard)).height;

    expect(shortTitleCardHeight, equals(longTitleCardHeight));
  });
}
