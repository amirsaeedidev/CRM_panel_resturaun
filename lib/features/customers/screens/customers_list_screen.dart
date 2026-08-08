import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../shared/widgets/pagination_widget.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 6;

  // Mock Data
  final List<Map<String, dynamic>> _customers = [
    {'id': 1, 'name': 'علی رضایی', 'phone': '09123456789', 'email': 'ali@example.com', 'orders': 12, 'spent': '4,500,000', 'status': 'فعال'},
    {'id': 2, 'name': 'سارا محمدی', 'phone': '09127654321', 'email': 'sara@example.com', 'orders': 5, 'spent': '1,200,000', 'status': 'فعال'},
    {'id': 3, 'name': 'حسین کریمی', 'phone': '09351112233', 'email': 'hossein@example.com', 'orders': 0, 'spent': '0', 'status': 'غیرفعال'},
    {'id': 4, 'name': 'مریم احمدی', 'phone': '09194445566', 'email': 'maryam@example.com', 'orders': 24, 'spent': '8,900,000', 'status': 'فعال'},
    {'id': 5, 'name': 'رضا قاسمی', 'phone': '09128889900', 'email': 'reza@example.com', 'orders': 2, 'spent': '560,000', 'status': 'مسدود'},
  ];

  ChipType _getStatusChipType(String status) {
    switch (status) {
      case 'فعال': return ChipType.success;
      case 'غیرفعال': return ChipType.warning;
      case 'مسدود': return ChipType.error;
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
          Text(
            'مدیریت مشتریان',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.getPrimaryText(context),
                  fontWeight: FontWeight.bold,
                ),
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
                      headers: const ['نام مشتری', 'شماره تماس', 'تعداد سفارش', 'مجموع خرید (تومان)', 'وضعیت', 'عملیات'],
                      rows: _customers.map((cust) {
                        return [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cust['name'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getPrimaryText(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                cust['email'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.getSecondaryText(context),
                                    ),
                              ),
                            ],
                          ),
                          Text(cust['phone'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
                          Text(cust['orders'].toString(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context))),
                          Text(cust['spent'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          CustomChip(
                            label: cust['status'],
                            type: _getStatusChipType(cust['status']),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, color: AppColors.info),
                                onPressed: () {
                                  // TODO: Navigate to Details screen
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.block_flipped, color: AppColors.error),
                                onPressed: () {
                                  // TODO: Implement block logic
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