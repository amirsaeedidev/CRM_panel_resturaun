import 'package:crm_panel/core/theme/app_radius.dart';
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
import '../../../providers/settings_provider.dart';

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
  
  final _minOrderController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SettingsProvider>();
      _minOrderController.text = provider.minDeliveryAmount?.toString() ?? '';
      _deliveryFeeController.text = provider.fixedDeliveryFee?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _companyPhoneController.dispose();
    _companyAddressController.dispose();
    _minOrderController.dispose();
    _deliveryFeeController.dispose();
    super.dispose();
  }

  Future<void> _pickColor(BuildContext context, bool isPrimary) async {
    final provider = context.read<SettingsProvider>();
    Color currentColor = isPrimary ? provider.primaryColor : provider.secondaryColor;

    Color? selectedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isPrimary ? 'انتخاب رنگ اصلی' : 'انتخاب رنگ ثانویه'),
          content: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Colors.blue, Colors.red, Colors.green, Colors.orange, 
              Colors.purple, Colors.teal, Colors.pink, Colors.indigo
            ].map((color) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('انصراف'),
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
      if (isPrimary) {
        provider.setPrimaryColor(selectedColor);
      } else {
        provider.setSecondaryColor(selectedColor);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    final data = {
      'min_delivery_amount': double.tryParse(_minOrderController.text) ?? 0,
      'fixed_delivery_fee': double.tryParse(_deliveryFeeController.text) ?? 0,
    };

    await context.read<SettingsProvider>().saveSettings(data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تنظیمات با موفقیت ذخیره شد'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    final settingsProvider = Provider.of<SettingsProvider>(context);

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

          // Branding & Colors (Prompt 14)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'برندینگ و رنگ‌ها',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.getPrimaryText(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(height: AppSizes.lg),
                
                // Live Preview
                Text('پیش‌نمایش زنده:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [settingsProvider.primaryColor, settingsProvider.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'نام رستوران',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.circular),
                        ),
                        child: Text(
                          'دکمه نمونه',
                          style: TextStyle(color: settingsProvider.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Color Pickers
                Wrap(
                  spacing: AppSizes.lg,
                  runSpacing: AppSizes.md,
                  children: [
                    _buildColorPickerItem(
                      context: context,
                      label: 'رنگ اصلی (Primary)',
                      color: settingsProvider.primaryColor,
                      onTap: () => _pickColor(context, true),
                    ),
                    _buildColorPickerItem(
                      context: context,
                      label: 'رنگ ثانویه (Secondary)',
                      color: settingsProvider.secondaryColor,
                      onTap: () => _pickColor(context, false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Delivery Settings (Prompt 14)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنظیمات ارسال',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.getPrimaryText(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(height: AppSizes.lg),
                Wrap(
                  spacing: AppSizes.md,
                  runSpacing: AppSizes.md,
                  children: [
                    SizedBox(
                      width: 250,
                      child: AppTextField(
                        controller: _minOrderController,
                        labelText: 'حداقل مبلغ سفارش (تومان)',
                        hintText: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: AppTextField(
                        controller: _deliveryFeeController,
                        labelText: 'هزینه ثابت ارسال (تومان)',
                        hintText: '0',
                        keyboardType: TextInputType.number,
                      ),
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
                isLoading: _isLoading,
                width: 150,
                onPressed: _saveSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerItem({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.getBorder(context)),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: AppSizes.sm),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}