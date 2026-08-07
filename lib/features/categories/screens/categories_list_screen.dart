import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../shared/widgets/pagination_widget.dart';
import '../../../shared/dialogs/delete_dialog.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 5;

  // Mock Data
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'الکترونیک', 'products': 45, 'status': 'فعال'},
    {'id': 2, 'name': 'پوشاک', 'products': 120, 'status': 'فعال'},
    {'id': 3, 'name': 'مواد غذایی', 'products': 80, 'status': 'غیرفعال'},
    {'id': 4, 'name': 'لوازم خانگی', 'products': 32, 'status': 'فعال'},
    {'id': 5, 'name': 'کتاب و لوازم تحریر', 'products': 56, 'status': 'فعال'},
  ];

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
                'مدیریت دسته‌بندی‌ها',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppButton(
                label: 'افزودن دسته جدید',
                icon: Icons.add_rounded,
                width: 200,
                onPressed: () {
                  // TODO: Navigate to Add/Edit screen
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
                      minWidth: 600,
                      headers: const ['نام دسته‌بندی', 'تعداد محصولات', 'وضعیت', 'عملیات'],
                      rows: _categories.map((cat) {
                        return [
                          Text(
                            cat['name'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.getPrimaryText(context),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            cat['products'].toString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.getSecondaryText(context),
                                ),
                          ),
                          CustomChip(
                            label: cat['status'],
                            type: cat['status'] == 'فعال' ? ChipType.success : ChipType.error,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () {
                                  // TODO: Navigate to Edit screen
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () {
                                  DeleteDialog.show(
                                    context: context,
                                    title: 'حذف دسته‌بندی',
                                    message: 'آیا از حذف دسته‌بندی "${cat['name']}" مطمئن هستید؟',
                                    onDelete: () {
                                      // TODO: Implement delete logic
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