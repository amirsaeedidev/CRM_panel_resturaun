import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:crm_panel/features/auth/screens/login_screen.dart';
import 'package:crm_panel/providers/auth_provider.dart';
import 'package:crm_panel/repositories/auth_repository.dart';
import 'package:crm_panel/models/user_model.dart';

class MockAuthRepository implements AuthRepository {
  @override
  UserModel? getCurrentUser() => null;

  @override
  Future<UserModel> login(String email, String password) async {
    return UserModel(
      id: 'test-id',
      email: email,
      firstName: 'Test',
      role: 'admin',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<UserModel> signUp(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword(String email) async {}
}

void main() {
  testWidgets('LoginScreen validates input and logs in successfully', (WidgetTester tester) async {
    // ساخت مسیریاب برای تست نویگیشن (context.go)
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Dashboard Page'))),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) {
          return ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(MockAuthRepository()),
            child: child!,
          );
        },
      ),
    );

    // بررسی وجود عنوان
    expect(find.text('پنل مدیریت رستوران'), findsOneWidget);

    // کلیک روی دکمه ورود بدون وارد کردن اطلاعات
    await tester.tap(find.text('ورود'));
    await tester.pumpAndSettle();

    // بررسی ارورهای ولیدیشن
    expect(find.text('ایمیل الزامی است'), findsOneWidget);
    expect(find.text('رمز عبور الزامی است'), findsOneWidget);

    // وارد کردن اطلاعات معتبر
    await tester.enterText(find.byType(TextFormField).first, 'admin@test.com');
    await tester.enterText(find.byType(TextFormField).last, '123456');

    // کلیک روی دکمه ورود
    await tester.tap(find.text('ورود'));
    
    // pumpAndSettle صبر می‌کند تا تمام تایمرها (مثل تاخیر ۱ ثانیه‌ای Mock) و انیمیشن‌ها تمام شوند
    // این کار از خطای Pending Timer جلوگیری می‌کند
    await tester.pumpAndSettle();

    // بررسی اینکه آیا به صفحه داشبورد منتقل شده‌ایم یا خیر
    expect(find.text('Dashboard Page'), findsOneWidget);
  });
}