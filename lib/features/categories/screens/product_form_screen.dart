import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/theme/app_radius.dart';

class ProductFormScreen extends StatefulWidget {
  final int? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  File? _selectedImage;
  bool _isLoading = false;

  bool get isEditing => widget.productId != null;

  // Mock categories for dropdown
  final List<String> _categories = ['الکترونیک', 'پوشاک', 'مواد غذایی', 'لوازم خانگی'];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
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
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لطفاً دسته‌بندی را انتخاب کنید'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isLoading = true);

      // TODO: Call Repository to save product
      if (_selectedImage != null) {
        // await UploadService.uploadFile(file: _selectedImage!, folderName: 'products');
      }
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate network request

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'محصول با موفقیت ویرایش شد' : 'محصول با موفقیت ایجاد شد'),
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
        title: Text(isEditing ? 'ویرایش محصول' : 'افزودن محصول جدید'),
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
                    width: 150,
                    height: 150,
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
                              Text('افزودن تصویر', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
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
                      'اطلاعات محصول',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _nameController,
                      labelText: 'نام محصول *',
                      hintText: 'مثال: گوشی موبایل سامسونگ',
                      validator: (value) => value!.isEmpty ? 'نام محصول الزامی است' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppDropdown<String>(
                      value: _selectedCategory,
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      labelText: 'دسته‌بندی *',
                      hintText: 'انتخاب دسته‌بندی',
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _priceController,
                            labelText: 'قیمت (تومان) *',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'قیمت الزامی است' : null,
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: AppTextField(
                            controller: _stockController,
                            labelText: 'موجودی *',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) => value!.isEmpty ? 'موجودی الزامی است' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _descriptionController,
                      labelText: 'توضیحات محصول',
                      hintText: 'توضیحات کامل محصول...',
                      maxLines: 4,
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