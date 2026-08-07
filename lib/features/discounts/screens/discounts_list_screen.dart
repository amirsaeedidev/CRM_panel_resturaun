import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../shared/widgets/pagination_widget.dart';
import '../../../shared/dialogs/delete_dialog.dart';

class DiscountsListScreen extends StatefulWidget {
  const DiscountsListScreen({super.key});

  @override
  State<DiscountsListScreen> createState() => _DiscountsListScreenState();
}

class _DiscountsListScreenState extends State<DiscountsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 4;

  // Mock Data
  final List<Map<String, dynamic>> _discounts = [
    {'id': 1, 'title': 'جشنواره تابستانه', 'code': 'SUMMER20', 'type': 'درصدی', 'value': '20%', 'end_date': '1403/09/30', 'status': 'فعال'},
    {'id': 2, 'title': 'تخفیف ویژه پوشاک', 'code': 'CLOTH50', 'type': 'مبلغی', 'value': '50,000 تومان', 'end_date': '1403/08/15', 'status': 'منقضی شده'},
    {'id': 3, 'title': 'تخفیف کاربران جدید', 'code': 'NEWUSER', 'type': 'درصدی', 'value': '15%', 'end_date': '1404/01/01', 'status': 'فعال'},
    {'id': 4, 'title': 'پایان سال', 'code': 'EOY30', 'type': 'درصدی', 'value': '30%', 'end_date': '1403/12/29', 'status': 'فعال'},
    {'id': 5, 'title': 'تخفیف لوازم خانگی', 'code': 'HOME10', 'type': 'مبلغی', 'value': '100,000 تومان', 'end_date': '1403/07/20', 'status': 'منقضی شده'},
  ];

  ChipType _getStatusChipType(String status) {
    switch (status) {
      case 'فعال': return ChipType.success;
      case 'منقضی شده': return ChipType.error;
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
                'مدیریت تخفیف‌ها',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppButton(
                label: 'افزودن تخفیف جدید',
                icon: Icons.add_rounded,
                width: 200,
                onPressed: () {
                  // TODO: Navigate to Add Discount screen
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
                      minWidth: 900,
                      headers: const ['عنوان', 'کد تخفیف', 'نوع', 'مقدار', 'تاریخ پایان', 'وضعیت', 'عملیات'],
                      rows: _discounts.map((disc) {
                        return [
                          Text(
                            disc['title'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.getPrimaryText(context),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(disc['code'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontFamily: 'monospace')),
                          Text(disc['type'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
                          Text(disc['value'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context))),
                          Text(disc['end_date'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
                          CustomChip(
                            label: disc['status'],
                            type: _getStatusChipType(disc['status']),
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
                                    title: 'حذف تخفیف',
                                    message: 'آیا از حذف تخفیف "${disc['title']}" مطمئن هستید؟',
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