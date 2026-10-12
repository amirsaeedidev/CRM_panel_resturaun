import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:crm_panel/core/widgets/app_button.dart';

// متد main حتماً باید وجود داشته باشد تا فلاتر بتواند تست‌ها را اجرا کند
void main() {
  testWidgets('AppButton displays label and icon correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'ذخیره',
            icon: Icons.save_outlined,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('ذخیره'), findsOneWidget);
    expect(find.byIcon(Icons.save_outlined), findsOneWidget);
  });

  testWidgets('AppButton triggers onPressed when tapped', (WidgetTester tester) async {
    bool pressed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'کلیک کنید',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(pressed, isTrue);
  });

  testWidgets('AppButton shows loading indicator and is disabled when isLoading is true', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            label: 'در حال ذخیره',
            isLoading: true,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    // متن دکمه نباید در حالت لودینگ نمایش داده شود
    expect(find.text('در حال ذخیره'), findsNothing);
    
    // باید اندیکاتور لودینگ (SpinKit) نمایش داده شود
    expect(find.byType(SpinKitThreeBounce), findsOneWidget);

    // کلیک روی دکمه در حالت لودینگ نباید باعث اجرای onPressed شود
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(pressed, isFalse);
  });
}