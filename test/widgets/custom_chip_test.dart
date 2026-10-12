import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_panel/core/widgets/custom_chip.dart';

void main() {
  testWidgets('CustomChip displays label and icon correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomChip(
            label: 'فعال',
            type: ChipType.success,
            icon: Icons.check_circle_outline,
          ),
        ),
      ),
    );

    expect(find.text('فعال'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('CustomChip triggers onDeleted when close icon is tapped', (WidgetTester tester) async {
    bool deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomChip(
            label: 'حذف کردن',
            type: ChipType.primary,
            onDeleted: () {
              deleted = true;
            },
          ),
        ),
      ),
    );

    // find.byIcon(Icons.close) finds the delete icon we added in the CustomChip
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(deleted, isTrue);
  });
}