import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:graduatio_project/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResQerApp());

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
