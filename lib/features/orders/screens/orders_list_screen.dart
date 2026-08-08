import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../shared/widgets/pagination_widget.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 12;

  // Mock Data
  final List<Map<String, dynamic>> _orders = [
    {'id': '#10234', 'customer': 'علی رضایی', 'date': '1403/08/12', 'amount': '1,500,000', 'status': 'در حال پردازش'},
    {'id': '#10233', 'customer': 'سارا محمدی', 'date': '1403/08/12', 'amount': '850,000', 'status': 'تحویل شده'},
    {'id': '#10232', 'customer': 'حسین کریمی', 'date': '1403/08/11', 'amount': '2,300,000', 'status': 'لغو شده'},
    {'id': '#10231', 'customer': 'مریم احمدی', 'date': '1403/08/11', 'amount': '500,000', 'status': 'ارسال شده'},
    {'id': '#10230', 'customer': 'رضا قاسمی', 'date': '1403/08/10', 'amount': '3,100,000', 'status': 'تحویل شده'},
  ];

  ChipType _getStatusChipType(String status) {
    switch (status) {
      case 'در حال پردازش': return ChipType.warning;
      case 'ارسال شده': return ChipType.info;
      case 'تحویل شده': return ChipType.success;
      case 'لغو شده': return ChipType.error;
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
            'مدیریت سفارشات',
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
                      headers: const ['شماره سفارش', 'مشتری', 'تاریخ', 'مبلغ (تومان)', 'وضعیت', 'عملیات'],
                      rows: _orders.map((order) {
                        return [
                          Text(
                            order['id'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(order['customer'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context), fontWeight: FontWeight.bold)),
                          Text(order['date'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
                          Text(order['amount'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context))),
                          CustomChip(
                            label: order['status'],
                            type: _getStatusChipType(order['status']),
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
                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                onPressed: () {
                                  // TODO: Open status change dialog
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