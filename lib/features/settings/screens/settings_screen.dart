import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/widgets/custom_switch.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController(text: 'مدیر سیستم');
  final _emailController = TextEditingController(text: 'admin@crm.com');
  final _companyNameController = TextEditingController(text: 'فروشگاه آنلاین من');
  final _companyPhoneController = TextEditingController(text: '02112345678');
  final _companyAddressController = TextEditingController(text: 'تهران، خیابان ولیعصر');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using Provider.of with listen false for methods, and context.read for actions
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تنظیمات پنل',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.getPrimaryText(context),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Profile Settings
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اطلاعات کاربری',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.getPrimaryText(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: AppSizes.md),
                    AppButton(
                      label: 'تغییر تصویر پروفایل',
                      type: AppButtonType.outline,
                      onPressed: () {},
                      width: 200,
                      height: 40,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _nameController,
                  labelText: 'نام و نام خانوادگی',
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _emailController,
                  labelText: 'ایمیل',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Appearance Settings
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنظیمات ظاهری',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.getPrimaryText(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(height: AppSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dark_mode_outlined, color: AppColors.getSecondaryText(context)),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          'حالت تیره (Dark Mode)',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.getPrimaryText(context),
                              ),
                        ),
                      ],
                    ),
                    CustomSwitch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Company Info
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اطلاعات فروشگاه',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.getPrimaryText(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppTextField(
                  controller: _companyNameController,
                  labelText: 'نام فروشگاه',
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _companyPhoneController,
                  labelText: 'شماره تماس',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _companyAddressController,
                  labelText: 'آدرس',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          
          // Save Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: AppStrings.save,
                icon: Icons.save_outlined,
                width: 150,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تنظیمات با موفقیت ذخیره شد'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}