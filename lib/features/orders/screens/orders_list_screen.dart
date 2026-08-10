import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_search.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../models/order_model.dart';
import '../../../providers/orders_provider.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;
import '../../../shared/widgets/pagination_widget.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormatter = NumberFormat.decimalPattern('en_US');
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd – HH:mm');

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ChipType _getStatusChipType(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ChipType.warning;
      case 'confirmed':
      case 'preparing':
        return ChipType.info;
      case 'shipped':
      case 'out_for_delivery':
        return ChipType.primary;
      case 'delivered':
        return ChipType.success;
      case 'cancelled':
        return ChipType.error;
      default:
        return ChipType.neutral;
    }
  }

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
            'Orders Management',
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
              context.read<OrdersProvider>().setSearchQuery(value);
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Content Area based on State
          Expanded(
            child: Consumer<OrdersProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.orders.isEmpty) {
                  return const Center(child: AppLoading());
                }

                if (provider.error != null && provider.orders.isEmpty) {
                  return app_error.AppErrorWidget(
                    message: provider.error!,
                    onRetry: () => provider.fetchOrders(),
                  );
                }

                if (provider.orders.isEmpty) {
                  return const EmptyWidget(
                    title: 'No Orders Found',
                    message: 'There are no orders matching your criteria.',
                    icon: Icons.receipt_long_outlined,
                  );
                }

                return AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: AppTable(
                          minWidth: 900,
                          headers: const [
                            'Order ID',
                            'Customer',
                            'Date',
                            'Amount',
                            'Status',
                            'Actions'
                          ],
                          rows: provider.orders.map((order) {
                            return [
                              Text(
                                '#${order.id.substring(0, 8).toUpperCase()}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                order.customerName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getPrimaryText(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                _dateFormatter.format(order.createdAt.toLocal()),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getSecondaryText(context),
                                    ),
                              ),
                              Text(
                                '${_currencyFormatter.format(order.totalAmount)} T',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getPrimaryText(context),
                                    ),
                              ),
                              CustomChip(
                                label: _formatStatus(order.status),
                                type: _getStatusChipType(order.status),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, color: AppColors.info),
                                    onPressed: () {
                                      context.push('/orders/details/${order.id}');
                                    },
                                  ),
                                  _buildStatusChangeMenu(context, order),
                                ],
                              ),
                            ];
                          }).toList(),
                        ),
                      ),
                      if (provider.totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: PaginationWidget(
                            currentPage: provider.currentPage,
                            totalPages: provider.totalPages,
                            onPageChanged: (page) {
                              provider.changePage(page);
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChangeMenu(BuildContext context, OrderModel order) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
      tooltip: 'Change Status',
      onSelected: (String newStatus) {
        context.read<OrdersProvider>().updateOrderStatus(order.id, newStatus);
      },
      itemBuilder: (context) {
        final statuses = [
          'pending',
          'confirmed',
          'preparing',
          'out_for_delivery',
          'delivered',
          'cancelled'
        ];
        return statuses.map((status) {
          return PopupMenuItem<String>(
            value: status,
            enabled: status != order.status.toLowerCase(),
            child: Row(
              children: [
                Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSizes.sm),
                Text(_formatStatus(status)),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}