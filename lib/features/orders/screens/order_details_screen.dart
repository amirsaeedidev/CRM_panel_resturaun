import 'package:crm_panel/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/order_model.dart';
import '../../../providers/orders_provider.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;
// import '../../../shared/dialogs/invoice_print_dialog.dart'; // Will be created in Prompt 3

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd – HH:mm');
  final TextEditingController _deliveryTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchOrderDetails(widget.orderId);
    });
  }

  @override
  void dispose() {
    _deliveryTimeController.dispose();
    super.dispose();
  }

  final List<String> _statusSteps = [
    'pending',
    'confirmed',
    'preparing',
    'out_for_delivery',
    'delivered'
  ];

  int _getCurrentStep(String status) {
    final index = _statusSteps.indexOf(status.toLowerCase());
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppColors.getSurface(context),
        foregroundColor: AppColors.getPrimaryText(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Customer Invoice',
            onPressed: () {
              // Interface for Prompt 3
              // InvoicePrintDialog.show(context, type: 'customer');
            },
          ),
          IconButton(
            icon: const Icon(Icons.kitchen_outlined),
            tooltip: 'Print Kitchen Invoice',
            onPressed: () {
              // Interface for Prompt 3
              // InvoicePrintDialog.show(context, type: 'kitchen');
            },
          ),
        ],
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetails) {
            return const Center(child: AppLoading());
          }

          if (provider.detailsError != null) {
            return app_error.AppErrorWidget(
              message: provider.detailsError!,
              onRetry: () => provider.fetchOrderDetails(widget.orderId),
            );
          }

          final order = provider.selectedOrder;

          if (order == null) {
            return const EmptyWidget(
              title: 'Order Not Found',
              message: 'The requested order could not be found.',
              icon: Icons.receipt_long_outlined,
            );
          }

          if (order.estimatedDeliveryTime != null && _deliveryTimeController.text.isEmpty) {
            _deliveryTimeController.text = order.estimatedDeliveryTime.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusStepper(context, provider, order),
                const SizedBox(height: AppSizes.lg),
                _buildOrderTypeInfo(context, order),
                const SizedBox(height: AppSizes.lg),
                _buildDeliveryTimeControl(context, provider, order),
                const SizedBox(height: AppSizes.lg),
                _buildItemsList(context, order),
                const SizedBox(height: AppSizes.lg),
                _buildSummary(context, order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusStepper(BuildContext context, OrdersProvider provider, OrderModel order) {
    int currentStep = _getCurrentStep(order.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_statusSteps.length, (index) {
                bool isCompleted = index < currentStep;
                bool isActive = index == currentStep;
                
                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted 
                                ? AppColors.success 
                                : (isActive ? AppColors.primary : AppColors.getBorder(context)),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : Icons.circle,
                            color: Colors.white,
                            size: isActive ? 16 : 12,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          _statusSteps[index].split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isActive ? AppColors.primary : AppColors.getSecondaryText(context),
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    if (index < _statusSteps.length - 1)
                      Container(
                        width: 60,
                        height: 2,
                        color: isCompleted ? AppColors.success : AppColors.getBorder(context),
                      ),
                  ],
                );
              }),
            ),
          ),
          if (currentStep < _statusSteps.length - 1) ...[
            const SizedBox(height: AppSizes.lg),
            AppButton(
              label: 'Advance Status',
              icon: Icons.arrow_forward,
              isLoading: provider.isUpdatingStatus,
              onPressed: () {
                provider.updateOrderStatus(order.id, _statusSteps[currentStep + 1]);
              },
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildOrderTypeInfo(BuildContext context, OrderModel order) {
    IconData icon;
    String title;
    String value;

    switch (order.orderType.toLowerCase()) {
      case 'dine_in':
        icon = Icons.restaurant;
        title = 'Dine In';
        value = 'Table: ${order.tableNumber ?? 'N/A'}';
        break;
      case 'pickup':
        icon = Icons.takeout_dining;
        title = 'Pickup';
        value = 'Customer will pick up';
        break;
      case 'delivery':
      default:
        icon = Icons.delivery_dining;
        title = 'Delivery';
        value = order.shippingAddress ?? 'N/A';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSizes.sm),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (order.orderType.toLowerCase() == 'delivery') ...[
            Text('Address:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.getSecondaryText(context))),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSizes.sm),
            Text('Postal Code:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.getSecondaryText(context))),
            Text(order.postalCode ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium),
          ] else if (order.orderType.toLowerCase() == 'dine_in') ...[
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[
            const Divider(height: AppSizes.lg),
            Text('Customer Note:', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
            Text(order.customerNote!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error)),
          ]
        ],
      ),
    );
  }

  Widget _buildDeliveryTimeControl(BuildContext context, OrdersProvider provider, OrderModel order) {
    if (order.orderType.toLowerCase() != 'delivery') return const SizedBox.shrink();

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Estimated Delivery Time (minutes)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: _deliveryTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined, color: AppColors.primary),
            onPressed: () {
              final minutes = int.tryParse(_deliveryTimeController.text);
              if (minutes != null) {
                provider.updateEstimatedDeliveryTime(order.id, minutes);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, OrderModel order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.quantity}x ${item.name}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (item.note != null && item.note!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.small),
                                ),
                                child: Text(
                                  'Item Note: ${item.note}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.price * item.quantity} T',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, OrderModel order) {
    return AppCard(
      child: Column(
        children: [
          _buildSummaryRow(context, 'Subtotal', '${order.totalAmount} T'),
          const SizedBox(height: AppSizes.sm),
          _buildSummaryRow(context, 'Delivery Fee', '0 T'), // Assuming fee is included or 0 for now
          const Divider(height: AppSizes.lg),
          _buildSummaryRow(
            context,
            'Total',
            '${order.totalAmount} T',
            isTotal: true,
          ),
          const SizedBox(height: AppSizes.sm),
          _buildSummaryRow(
            context,
            'Order Date',
            _dateFormatter.format(order.createdAt.toLocal()),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context)),
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}