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
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/widgets/custom_switch.dart';
import '../../../models/discount_model.dart';
import '../../../providers/banners_provider.dart';
import '../../../providers/discounts_provider.dart';

class BannerFormScreen extends StatefulWidget {
  final String? bannerId;

  const BannerFormScreen({super.key, this.bannerId});

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priorityController = TextEditingController(text: '1');
  
  File? _selectedImage;
  String? _selectedDiscountId;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.bannerId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch discounts for dropdown
      context.read<DiscountsProvider>().fetchDiscounts();
      
      if (isEditing) {
        final provider = context.read<BannersProvider>();
        final banner = provider.getBannerById(widget.bannerId!);
        if (banner != null) {
          _titleController.text = banner.title;
          _priorityController.text = banner.displayOrder.toString();
          _selectedDiscountId = banner.actionUrl; // Assuming actionUrl stores the discount ID
          _isActive = banner.isActive;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
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

  String? _validatePriority(String? value) {
    if (value == null || value.isEmpty) return 'Priority is required';
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
      imageUrl = await UploadService.uploadFile(
        file: _selectedImage!,
        folderName: 'banners',
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

    final bannerData = {
      'title': _titleController.text,
      'display_order': int.parse(_priorityController.text),
      'is_active': _isActive,
      'action_url': _selectedDiscountId, // Store selected discount ID
      'image_url': ?imageUrl,
    };

    try {
      final provider = context.read<BannersProvider>();
      if (isEditing) {
        await provider.updateBanner(widget.bannerId!, bannerData);
      } else {
        await provider.createBanner(bannerData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Banner updated successfully' : 'Banner created successfully'),
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
        title: Text(isEditing ? 'Edit Banner' : 'Add New Banner'),
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
                              Text(
                                'Add Banner Image',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      'Banner Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _titleController,
                      labelText: 'Banner Title *',
                      hintText: 'e.g., Summer Sale',
                      validator: (value) => value!.isEmpty ? 'Title is required' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    
                    // Discount Dropdown
                    Consumer<DiscountsProvider>(
                      builder: (context, discountProvider, child) {
                        if (discountProvider.isLoading && discountProvider.discounts.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (discountProvider.error != null && discountProvider.discounts.isEmpty) {
                          return Text('Error loading discounts: ${discountProvider.error}');
                        }
                        if (discountProvider.discounts.isEmpty) {
                          return const Text('No discounts available. Please create a discount first.');
                        }

                        return AppDropdown<String>(
                          value: _selectedDiscountId,
                          items: discountProvider.discounts
                              .map((DiscountModel discount) => DropdownMenuItem(
                                    value: discount.id,
                                    child: Text('${discount.title} (${discount.code})'),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedDiscountId = value),
                          labelText: 'Select Related Discount Code',
                          hintText: 'None',
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _priorityController,
                      labelText: 'Slider Display Priority *',
                      hintText: '1',
                      keyboardType: TextInputType.number,
                      validator: _validatePriority,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Settings Card
              AppCard(
                child: SwitchListTile(
                  title: const Text('Active Banner'),
                  subtitle: const Text('If disabled, banner will not be shown in the app'),
                  value: _isActive,
                  activeThumbColor: AppColors.primary,
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