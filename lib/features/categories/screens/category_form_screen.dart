import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../providers/categories_provider.dart';

class CategoryFormScreen extends StatefulWidget {
  final String? categoryId;

  const CategoryFormScreen({super.key, this.productId});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sortOrderController = TextEditingController(text: '0');
  final _loyaltyPointsController = TextEditingController(text: '0');
  
  File? _selectedImage;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Fetch existing category data via Provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<CategoriesProvider>();
        final category = provider.getCategoryById(widget.categoryId!);
        if (category != null) {
          _nameController.text = category.name;
          _descriptionController.text = category.description ?? '';
          _sortOrderController.text = category.displayOrder.toString();
          // Assuming loyaltyPoints might exist in future model or default to 0
          _loyaltyPointsController.text = '0'; 
          _isActive = category.isActive;
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    _loyaltyPointsController.dispose();
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

  String? _validatePositiveInteger(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final num = int.tryParse(value);
    if (num == null) return 'Invalid number';
    if (num < 0) return 'Cannot be negative';
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? imageUrl;
    if (_selectedImage != null) {
      // Upload image via UploadService
      imageUrl = await UploadService.uploadFile(
        file: _selectedImage!,
        folderName: 'categories',
      );
      
      if (imageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image upload failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
    }

    final categoryData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'display_order': int.parse(_sortOrderController.text),
      'loyalty_points_per_item': int.parse(_loyaltyPointsController.text),
      'is_active': _isActive,
      if (imageUrl != null) 'image_url': imageUrl,
    };

    try {
      final provider = context.read<CategoriesProvider>();
      if (isEditing) {
        await provider.updateCategory(widget.categoryId!, categoryData);
      } else {
        await provider.createCategory(categoryData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Category updated successfully' : 'Category created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
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
                    width: 120,
                    height: 120,
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
                              Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.getSecondaryText(context)),
                              const SizedBox(height: AppSizes.sm),
                              Text(
                                'Add Image',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.getSecondaryText(context),
                                    ),
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
                      'Category Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _nameController,
                      labelText: 'Category Name *',
                      hintText: 'e.g., Beverages',
                      validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      hintText: 'Short description...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSizes.md),
                    
                    // Numeric Fields Responsive
                    Wrap(
                      spacing: AppSizes.md,
                      runSpacing: AppSizes.md,
                      children: [
                        SizedBox(
                          width: 200,
                          child: AppTextField(
                            controller: _sortOrderController,
                            labelText: 'Sort Order *',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: _validatePositiveInteger,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: AppTextField(
                            controller: _loyaltyPointsController,
                            labelText: 'Loyalty Points Per Item *',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: _validatePositiveInteger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Settings Card
              AppCard(
                child: SwitchListTile(
                  title: const Text('Active Category'),
                  subtitle: const Text('If disabled, category will not be visible to customers'),
                  value: _isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
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