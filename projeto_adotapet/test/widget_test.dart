// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:projeto_adotapet/main.dart';

void main() {
  testWidgets('App loads and shows HomePage', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const AdotaPetApp());

    // Verify HomePage is shown by checking for a stable label in the
    // BottomNavigationBar.
    expect(find.text('Feed'), findsOneWidget);
  });
}
