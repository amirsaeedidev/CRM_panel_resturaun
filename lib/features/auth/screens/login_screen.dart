import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    await provider.login(_emailController.text.trim(), _passwordController.text.trim());

    if (!mounted) return;

    if (provider.isAuthenticated) {
      context.go(AppRoutes.dashboard);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header / Logo
                  Container(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.restaurant_menu, size: 64, color: Colors.white),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'پنل مدیریت رستوران',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Welcome Text
                  Text(
                    AppStrings.welcomeBack,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPrimaryText(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'لطفاً برای ادامه وارد حساب کاربری خود شوید',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.getSecondaryText(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Email Field
                  AppTextField(
                    controller: _emailController,
                    labelText: AppStrings.email,
                    hintText: 'admin@example.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'ایمیل الزامی است';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'فرمت ایمیل نامعتبر است';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Password Field
                  AppTextField(
                    controller: _passwordController,
                    labelText: AppStrings.password,
                    hintText: '********',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.getSecondaryText(context),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'رمز عبور الزامی است';
                      if (value.length < 6) return 'رمز عبور حداقل ۶ کاراکتر باشد';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Login Button
                  AppButton(
                    label: AppStrings.login,
                    isLoading: provider.isLoading,
                    onPressed: _submitLogin,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}