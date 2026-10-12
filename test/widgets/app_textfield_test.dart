import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_panel/core/widgets/app_textfield.dart';

void main() {
  testWidgets('AppTextField displays label and hint text correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            labelText: 'نام کاربری',
            hintText: 'ایمیل خود را وارد کنید',
          ),
        ),
      ),
    );

    expect(find.text('نام کاربری'), findsOneWidget);
    expect(find.text('ایمیل خود را وارد کنید'), findsOneWidget);
  });

  testWidgets('AppTextField shows error text when provided',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            labelText: 'رمز عبور',
            errorText: 'رمز عبور خیلی کوتاه است',
          ),
        ),
      ),
    );

    expect(find.text('رمز عبور خیلی کوتاه است'), findsOneWidget);
  });

  testWidgets('AppTextField hides text content when obscureText is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            labelText: 'رمز عبور',
            obscureText: true,
          ),
        ),
      ),
    );

    // تایپ کردن متن در فیلد
    await tester.enterText(find.byType(TextFormField), 'mySecretPassword');
    await tester.pump();

    // به جای جستجوی متن (که در EditableText وجود دارد)، باید ویژگی obscureText را بررسی کنیم
    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.obscureText, isTrue);
  });
}