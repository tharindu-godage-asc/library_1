// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:library_1/features/auth/presentation/screens/splash_screen.dart';
import 'package:library_1/main.dart';

void main() {
  testWidgets('App shows the splash screen on cold start', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LibraryApp()));

    expect(find.byType(SplashScreen), findsOneWidget);

    // Flush the splash screen's minimum-hold timer so no timer is left
    // pending when the test tears down.
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
