import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_button.dart';
import '../../models/order_model.dart';

class InvoicePrintDialog extends StatelessWidget {
  final OrderModel order;
  final String invoiceType; // 'customer' or 'kitchen'

   InvoicePrintDialog({
    super.key,
    required this.order,
    this.invoiceType = 'customer',
  });

  static Future<void> show({
    required BuildContext context,
    required OrderModel order,
    String invoiceType = 'customer',
  }) {
    return showDialog(
      context: context,
      builder: (context) => InvoicePrintDialog(
        order: order,
        invoiceType: invoiceType,
      ),
    );
  }

  final NumberFormat _currencyFormatter = NumberFormat.decimalPattern('en_US');
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  Widget build(BuildContext context) {
    bool isKitchen = invoiceType == 'kitchen';
    double receiptWidth = 320; // Approx 80mm at ~4px/mm

    return Dialog(
      backgroundColor: AppColors.getSurface(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isKitchen ? 'Kitchen Invoice Preview' : 'Customer Invoice Preview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.getPrimaryText(context),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Receipt Preview Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Center(
                  child: Container(
                    width: receiptWidth,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.getBorder(context).withOpacity(0.5)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo & Header
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.restaurant_menu, size: 40, color: Colors.grey[800]),
                              const SizedBox(height: AppSizes.sm),
                              Text(
                                'Restaurant Name',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              Text(
                                '123 Restaurant St, City',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Tel: 021-12345678',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _dashedDivider(),
                        // Order Info
                        _buildReceiptRow('Order ID:', '#${order.id.substring(0, 8).toUpperCase()}'),
                        _buildReceiptRow('Date:', _dateFormatter.format(order.createdAt.toLocal())),
                        _buildReceiptRow('Customer:', order.customerName),
                        _buildReceiptRow('Type:', order.orderType.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')),
                        
                        if (order.orderType.toLowerCase() == 'dine_in' && order.tableNumber != null)
                          _buildReceiptRow('Table No:', order.tableNumber!),
                        
                        if (order.orderType.toLowerCase() == 'delivery') ...[
                          if (order.shippingAddress != null)
                            _buildReceiptRow('Address:', order.shippingAddress!, maxLines: 2),
                          if (order.postalCode != null)
                            _buildReceiptRow('Postal Code:', order.postalCode!),
                        ],

                        if (order.customerNote != null && order.customerNote!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSizes.xs),
                            color: Colors.red[50],
                            child: Text(
                              'NOTE: ${order.customerNote}',
                              style: TextStyle(fontSize: 12, color: Colors.red[800], fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],

                        _dashedDivider(),
                        
                        // Items
                        if (isKitchen) ...[
                          Text('*** KITCHEN COPY ***', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          const SizedBox(height: AppSizes.sm),
                        ] else ...[
                          Text('ITEMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          const SizedBox(height: AppSizes.sm),
                        ],

                        ...order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity}x  ${item.name}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (!isKitchen)
                                      Text(
                                        _currencyFormatter.format(item.price * item.quantity),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                                if (item.note != null && item.note!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0, top: 2.0),
                                    child: Text(
                                      '- ${item.note}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),

                        _dashedDivider(),

                        // Summary
                        if (!isKitchen) ...[
                          _buildReceiptRow('Subtotal:', '${_currencyFormatter.format(order.totalAmount)} T'),
                          _buildReceiptRow('Discount:', '0 T'),
                          _buildReceiptRow('Delivery Fee:', '0 T'),
                          _dashedDivider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${_currencyFormatter.format(order.totalAmount)} T', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ] else ...[
                          Center(
                            child: Text(
                              'PREPARE TIME: ${_dateFormatter.format(order.createdAt.toLocal())}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSizes.md),
                        Center(
                          child: Text(
                            'Thank You!',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            // Actions
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Close',
                    type: AppButtonType.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSizes.md),
                  AppButton(
                    label: 'Print Thermal Invoice',
                    icon: Icons.print_outlined,
                    onPressed: () {
                      // Interface ready for real Print Service
                      // Example: PrintService.print(order, type: invoiceType);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Print command sent to service.'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: CustomPaint(
        size: const Size(double.infinity, 1),
        painter: DashedLinePainter(),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3;
    double startX = 0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}