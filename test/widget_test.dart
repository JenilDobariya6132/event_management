// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:event/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RoyalWeddingApp());
    expect(find.byType(RoyalWeddingApp), findsOneWidget);
  });
}
