import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../core/theme/app_radius.dart';

class ProductDetailsScreen extends StatelessWidget {
  final int productId;

  const ProductDetailsScreen({super.key, required this.productId});

  // Mock Data
  Map<String, dynamic> get _product => {
        'name': 'گوشی موبایل سامسونگ A52',
        'category': 'الکترونیک',
        'price': '12,500,000 تومان',
        'stock': 24,
        'status': 'موجود',
        'description': 'گوشی هوشمند سامسونگ مدل A52 با دوربین ۴ لنزی، نمایشگر AMOLED و باتری ۴۵۰۰ میلی‌آمپری. مناسب برای بازی و کارهای روزمره.',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('جزئیات محصول'),
        backgroundColor: AppColors.getSurface(context),
        foregroundColor: AppColors.getPrimaryText(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {
              // TODO: Navigate to Edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              // TODO: Show Delete Dialog
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.getSurface(context),
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.getBorder(context), width: 1),
                ),
                child: Icon(Icons.image_outlined, size: 80, color: AppColors.getSecondaryText(context)),
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Title & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _product['name'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.getPrimaryText(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                CustomChip(
                  label: _product['status'],
                  type: ChipType.success,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Price & Stock Cards
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قیمت محصول',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.getSecondaryText(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          _product['price'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'موجودی انبار',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.getSecondaryText(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '${_product['stock']} عدد',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.getPrimaryText(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Category
            AppCard(
              child: Row(
                children: [
                  Icon(Icons.category_outlined, color: AppColors.getSecondaryText(context)),
                  const SizedBox(width: AppSizes.md),
                  Text(
                    'دسته‌بندی: ',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.getSecondaryText(context),
                        ),
                  ),
                  Text(
                    _product['category'],
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.getPrimaryText(context),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Description
            Text(
              'توضیحات محصول',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.getPrimaryText(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),
            AppCard(
              child: Text(
                _product['description'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getSecondaryText(context),
                      height: 1.8,
                    ),
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Action Button
            AppButton(
              label: 'ویرایش محصول',
              icon: Icons.edit_outlined,
              onPressed: () {
                // TODO: Navigate to Edit screen
              },
            ),
          ],
        ),
      ),
    );
  }
}