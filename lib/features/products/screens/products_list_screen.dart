import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../shared/widgets/pagination_widget.dart';
import '../../../shared/dialogs/delete_dialog.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 8;

  // Mock Data
  final List<Map<String, dynamic>> _products = [
    {'id': 1, 'name': 'گوشی موبایل سامسونگ A52', 'category': 'الکترونیک', 'price': '12,500,000', 'stock': 24, 'status': 'موجود'},
    {'id': 2, 'name': 'لپ‌تاپ ایسوس Zenbook', 'category': 'الکترونیک', 'price': '45,000,000', 'stock': 0, 'status': 'ناموجود'},
    {'id': 3, 'name': 'پیراهن مردانه یقه اسکی', 'category': 'پوشاک', 'price': '850,000', 'stock': 120, 'status': 'موجود'},
    {'id': 4, 'name': 'روغن مایع آفتاب', 'category': 'مواد غذایی', 'price': '120,000', 'stock': 5, 'status': 'رو به اتمام'},
    {'id': 5, 'name': 'هدفون بلوتوثی جی‌بی‌ال', 'category': 'الکترونیک', 'price': '3,200,000', 'stock': 45, 'status': 'موجود'},
  ];

  ChipType _getChipType(String status) {
    switch (status) {
      case 'موجود': return ChipType.success;
      case 'ناموجود': return ChipType.error;
      case 'رو به اتمام': return ChipType.warning;
      default: return ChipType.neutral;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مدیریت محصولات',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppButton(
                label: 'افزودن محصول جدید',
                icon: Icons.add_rounded,
                width: 200,
                onPressed: () {
                  context.push('/products/add');
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Search Bar
          AppSearch(
            controller: _searchController,
            onChanged: (value) {
              // TODO: Implement search logic
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Table Area
          Expanded(
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Expanded(
                    child: AppTable(
                      minWidth: 800,
                      headers: const ['نام محصول', 'دسته‌بندی', 'قیمت (تومان)', 'موجودی', 'وضعیت', 'عملیات'],
                      rows: _products.map((prod) {
                        return [
                          Text(
                            prod['name'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.getPrimaryText(context),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(prod['category'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
                          Text(prod['price'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context))),
                          Text(prod['stock'].toString(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
                          CustomChip(
                            label: prod['status'],
                            type: _getChipType(prod['status']),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, color: AppColors.info),
                                onPressed: () {
                                  context.push('/products/details/${prod['id']}');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () {
                                  context.push('/products/edit/${prod['id']}');
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () {
                                  DeleteDialog.show(
                                    context: context,
                                    title: 'حذف محصول',
                                    message: 'آیا از حذف محصول "${prod['name']}" مطمئن هستید؟',
                                    onDelete: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('محصول حذف شد (شبیه‌سازی)'), backgroundColor: AppColors.success),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ];
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: PaginationWidget(
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}