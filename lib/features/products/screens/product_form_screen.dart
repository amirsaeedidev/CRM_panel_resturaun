import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../core/theme/app_radius.dart';
import '../../../providers/products_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  File? _selectedImage;
  bool _isPopular = false;
  bool _isAvailable = true;
  bool _isLoading = false;

  bool get isEditing => widget.productId != null;

  // Mock categories for dropdown - In production, this comes from CategoriesProvider
  final List<String> _categories = ['Electronics', 'Clothing', 'Food', 'Home Appliances'];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      // Fetch existing product data via Provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<ProductsProvider>();
        final product = provider.getProductById(widget.productId!);
        if (product != null) {
          _nameController.text = product.name;
          _priceController.text = product.price.toString();
          _discountedPriceController.text = product.discountedPrice?.toString() ?? '';
          _stockController.text = product.stock.toString();
          _descriptionController.text = product.description;
          _selectedCategory = product.categoryId;
          _isPopular = product.isPopular;
          _isAvailable = product.status == 'active';
          // _selectedImage = product.imageUrl; // Can't assign String to File directly
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountedPriceController.dispose();
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

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    final price = double.tryParse(value);
    if (price == null) return 'Invalid number';
    if (price < 0) return 'Price cannot be negative';
    return null;
  }

  String? _validateDiscountedPrice(String? value) {
    if (value == null || value.isEmpty) return null; // Optional
    
    final discountedPrice = double.tryParse(value);
    if (discountedPrice == null) return 'Invalid number';
    if (discountedPrice < 0) return 'Discount cannot be negative';
    
    final originalPrice = double.tryParse(_priceController.text);
    if (originalPrice != null && discountedPrice >= originalPrice) {
      return 'Must be less than original price';
    }
    
    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? imageUrl;
    if (_selectedImage != null) {
      // imageUrl = await UploadService.uploadFile(file: _selectedImage!, folderName: 'products');
      // Simulating upload for structure
      await Future.delayed(const Duration(seconds: 1));
      imageUrl = 'https://via.placeholder.com/150';
    }

    final productData = {
      'name': _nameController.text,
      'price': double.parse(_priceController.text),
      'discounted_price': _discountedPriceController.text.isEmpty 
          ? null 
          : double.parse(_discountedPriceController.text),
      'stock': int.parse(_stockController.text),
      'description': _descriptionController.text,
      'category_id': _selectedCategory,
      'image_url': imageUrl, // Should be handled by provider/repo
      'is_popular': _isPopular,
      'status': _isAvailable ? 'active' : 'inactive',
    };

    try {
      final provider = context.read<ProductsProvider>();
      if (isEditing) {
        await provider.updateProduct(widget.productId!, productData);
      } else {
        await provider.createProduct(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Product updated successfully' : 'Product created successfully'),
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
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
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
                              Text(
                                'Add Image',
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
                      'Product Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      controller: _nameController,
                      labelText: 'Product Name *',
                      hintText: 'e.g., Samsung Galaxy A52',
                      validator: (value) => value!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppDropdown<String>(
                      value: _selectedCategory,
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      labelText: 'Category *',
                      hintText: 'Select Category',
                    ),
                    const SizedBox(height: AppSizes.md),
                    
                    // Price & Stock - Responsive
                    Wrap(
                      spacing: AppSizes.md,
                      runSpacing: AppSizes.md,
                      children: [
                        SizedBox(
                          width: 200,
                          child: AppTextField(
                            controller: _priceController,
                            labelText: 'Price (Toman) *',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: _validatePrice,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: AppTextField(
                            controller: _discountedPriceController,
                            labelText: 'Discounted Price (Toman)',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: _validateDiscountedPrice,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: AppTextField(
                            controller: _stockController,
                            labelText: 'Stock *',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Stock is required';
                              if (int.tryParse(value) == null) return 'Invalid number';
                              if (int.parse(value) < 0) return 'Cannot be negative';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      hintText: 'Full product description...',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Settings Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.getPrimaryText(context),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Divider(height: AppSizes.lg),
                    SwitchListTile(
                      title: const Text('Available for Customers'),
                      subtitle: const Text('If disabled, product will not be shown in the menu'),
                      value: _isAvailable,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isAvailable = val),
                    ),
                    SwitchListTile(
                      title: const Text('Show in Popular Products'),
                      subtitle: const Text('Highlight this product on the dashboard'),
                      value: _isPopular,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isPopular = val),
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