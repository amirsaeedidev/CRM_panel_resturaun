import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/table_model.dart';
import '../../../providers/tables_provider.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;

class TablesGridScreen extends StatefulWidget {
  const TablesGridScreen({super.key});

  @override
  State<TablesGridScreen> createState() => _TablesGridScreenState();
}

class _TablesGridScreenState extends State<TablesGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<TablesProvider>().fetchTables();
    });
  }

  // Helper to get colors based on table status
  Color _getStatusColor(TableStatus status, BuildContext context) {
    switch (status) {
      case TableStatus.free:
        return AppColors.success;
      case TableStatus.occupied:
        return AppColors.error;
      case TableStatus.reserved:
        return AppColors.warning;
    }
  }

  void _showTableActions(BuildContext context, TableModel table) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.large)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Table ${table.tableNumber}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Status: ${table.status.name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _getStatusColor(table.status, context)),
                ),
                const Divider(height: AppSizes.xl),
                if (table.status == TableStatus.occupied && table.currentOrderId != null)
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.info),
                    title: const Text('View Active Order'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/orders/details/${table.currentOrderId}');
                    },
                  ),
                if (table.status == TableStatus.free)
                  ListTile(
                    leading: const Icon(Icons.add_shopping_cart, color: AppColors.primary),
                    title: const Text('Create New Order'),
                    onTap: () {
                      Navigator.pop(context);
                      // context.push('/orders/add?tableId=${table.id}');
                    },
                  ),
                if (table.status != TableStatus.free)
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined, color: AppColors.success),
                    title: const Text('Mark Table as Free'),
                    onTap: () {
                      Navigator.pop(context);
                      // context.read<TablesProvider>().markTableAsFree(table.id);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy state for UI structure. Replace with Consumer<TablesProvider>
    final bool isLoading = false;
    final String? error = null;
    final List<TableModel> tables = [];
    final bool isEmpty = tables.isEmpty && !isLoading && error == null;

    if (isLoading) {
      return const Center(child: AppLoading());
    }

    if (error != null) {
      return app_error.AppErrorWidget(
        message: error,
        onRetry: () {
          // context.read<TablesProvider>().fetchTables();
        },
      );
    }

    if (isEmpty) {
      return const EmptyWidget(
        title: 'No Tables Found',
        message: 'Please add tables in the database to see them here.',
        icon: Icons.table_restaurant_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant Tables',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.lg),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
                crossAxisSpacing: AppSizes.md,
                mainAxisSpacing: AppSizes.md,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                final statusColor = _getStatusColor(table.status, context);

                return AppCard(
                  padding: EdgeInsets.zero,
                  onTap: () => _showTableActions(context, table),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: statusColor, width: 5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'T-${table.tableNumber}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.table_restaurant, color: statusColor.withOpacity(0.5)),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${table.capacity} Seats',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.getSecondaryText(context),
                                ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppRadius.small),
                            ),
                            child: Text(
                              table.status.name.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (table.status == TableStatus.occupied && table.currentOrderId != null) ...[
                            const SizedBox(height: AppSizes.sm),
                            Text(
                              'Order: #${table.currentOrderId!.substring(0, 6).toUpperCase()}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}