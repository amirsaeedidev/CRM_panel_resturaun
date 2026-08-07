import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/widgets/custom_switch.dart';
import '../../../core/theme/app_radius.dart';

class BannerFormScreen extends StatefulWidget {
  final int? bannerId;

  const BannerFormScreen({super.key, this.bannerId});

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  File? _selectedImage;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.bannerId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await UploadService.pickImageFromGallery();
    if (xFile != null) {
      setState(() {
        _selectedImage = File(xFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null && !isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً تصویر بنر را آپلود کنید'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isLoading = true);

      // TODO: Call Repository to save banner
      if (_selectedImage != null) {
        // await UploadService.uploadFile(file: _selectedImage!, folderName: 'banners');
      }

      await Future.delayed(const Duration(seconds: 2)); // Simulate network request

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'بنر با موفقیت ویرایش شد' : 'بنر با موفقیت ایجاد شد'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(isEditing ? 'ویرایش بنر' : 'افزودن بنر جدید'),
        backgroundColor: AppColors.getSurface(context),
        foregroundColor: AppColors.getPrimaryText(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.getBackground(context),
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border: Border.all(color: AppColors.getBorder(context), width: 2),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.large),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.getSecondaryText(context)),
                              const SizedBox(height: AppSizes.sm),
                              Text('افزودن تصویر بنر (حداکثر尺寸 1920x600)', 
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context)),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Basic Info Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اطلاعات بنر',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _titleController,
                      labelText: 'عنوان بنر *',
                      hintText: 'مثال: جشنواره تابستانه',
                      validator: (value) => value!.isEmpty ? 'عنوان بنر الزامی است' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _orderController,
                      labelText: 'ترتیب نمایش *',
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'ترتیب نمایش الزامی است' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'وضعیت بنر',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.getPrimaryText(context),
                              ),
                        ),
                        CustomSwitch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      _isActive ? 'فعال (نمایش داده می‌شود)' : 'غیرفعال (پنهان است)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.getSecondaryText(context),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: AppStrings.cancel,
                    type: AppButtonType.outline,
                    width: 120,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSizes.md),
                  AppButton(
                    label: AppStrings.save,
                    isLoading: _isLoading,
                    width: 120,
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}