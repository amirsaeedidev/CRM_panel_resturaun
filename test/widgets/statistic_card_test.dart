import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_panel/core/constants/app_colors.dart';
import 'package:crm_panel/features/dashboard/widgets/statistic_card.dart';

void main() {
  testWidgets('StatisticCard displays title, value, and percentage correctly',
      (WidgetTester tester) async {
    // آرایه‌ای از ویجت‌های مورد نیاز برای تست
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatisticCard(
            title: 'فروش کل',
            value: '45,200,000 T',
            icon: Icons.attach_money,
            iconColor: AppColors.success,
            changePercentage: '12',
            isPositiveChange: true,
          ),
        ),
      ),
    );

    // بررسی نمایش متن عنوان
    expect(find.text('فروش کل'), findsOneWidget);
    // بررسی نمایش متن مقدار
    expect(find.text('45,200,000 T'), findsOneWidget);
    // بررسی نمایش درصد رشد
    expect(find.text('12%'), findsOneWidget);
    // بررسی وجود آیکون
    expect(find.byIcon(Icons.attach_money), findsOneWidget);
    // بررسی وجود آیکون رشد مثبت
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });

  testWidgets('StatisticCard displays negative growth correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatisticCard(
            title: 'سفارشات لغو شده',
            value: '15',
            icon: Icons.cancel_outlined,
            iconColor: AppColors.error,
            changePercentage: '5',
            isPositiveChange: false, // رشد منفی
          ),
        ),
      ),
    );

    expect(find.text('15'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget); // آیکون رشد منفی
  });
}