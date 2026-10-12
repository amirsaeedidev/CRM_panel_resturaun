import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crm_panel/core/constants/app_colors.dart';
import 'package:crm_panel/features/auth/screens/login_screen.dart';
import 'package:crm_panel/providers/auth_provider.dart';
import 'package:crm_panel/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  UserModel? getCurrentUser() => null;

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
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
  testWidgets('LoginScreen renders correctly and validates input', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(MockAuthRepository()),
          child: const LoginScreen(),
        ),
      ),
    );

    // Verify that the header text is present.
    expect(find.text('پنل مدیریت رستوران'), findsOneWidget);

    // Verify that email and password fields are present.
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Try to tap the login button without entering anything (should show validation errors).
    await tester.tap(find.text('ورود'));
    await tester.pump();

    // Verify validation errors are shown.
    expect(find.text('ایمیل الزامی است'), findsOneWidget);
    expect(find.text('رمز عبور الزامی است'), findsOneWidget);

    // Enter valid credentials.
    await tester.enterText(find.byType(TextFormField).first, 'admin@test.com');
    await tester.enterText(find.byType(TextFormField).last, '123456');

    // Tap the login button again.
    await tester.tap(find.text('ورود'));
    await tester.pump(); // Start the async call

    // Verify that loading indicator is shown.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}