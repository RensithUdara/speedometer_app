import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedometer/main.dart';

void main() {
  testWidgets('speedometer dashboard shows trip controls and stats',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('KM/H'), findsWidgets);
    expect(find.text('MPH'), findsOneWidget);
    expect(find.text('Brake'), findsOneWidget);
    expect(find.text('Accelerator'), findsOneWidget);
    expect(find.text('Average'), findsOneWidget);
    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Trip Time'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
  });
}
