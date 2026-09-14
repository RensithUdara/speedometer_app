import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedometer/main.dart';

void main() {
  testWidgets('speedtrack dashboard shows controls, stats, and tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('SpeedTrack'), findsOneWidget);
    expect(find.text('Drive Safe, Go Further'), findsOneWidget);
    expect(find.text('KM/H'), findsWidgets);
    expect(find.text('MPH'), findsOneWidget);
    expect(find.text('Brake'), findsOneWidget);
    expect(find.text('Accelerator'), findsOneWidget);
    expect(find.text('Average Speed'), findsOneWidget);
    expect(find.text('Max Speed'), findsOneWidget);
    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Distance Goal'), findsOneWidget);
    expect(find.text('Trip Time'), findsOneWidget);
    expect(find.text('Safety Score'), findsOneWidget);
    expect(find.text('Over Limit'), findsOneWidget);
    expect(find.text('Cruise Control'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);

    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    expect(find.text('Current drive summary'), findsOneWidget);
    expect(find.text('Save Trip'), findsOneWidget);

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(find.text('No saved trips yet'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Driving preferences'), findsOneWidget);
    expect(find.text('Safety Alerts'), findsOneWidget);
    expect(find.text('Eco Mode'), findsOneWidget);
    expect(find.text('Cruise Control'), findsOneWidget);
  });
}
