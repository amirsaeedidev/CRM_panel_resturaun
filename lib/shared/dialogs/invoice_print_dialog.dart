import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/app_button.dart';
import '../../models/order_model.dart';

class InvoicePrintDialog extends StatelessWidget {
  final OrderModel order;
  final String invoiceType; // 'customer' or 'kitchen'

  // Removed 'const' here to avoid potential linter errors with non-const models
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

    // Removed Directionality wrapper to fix IDE glitch
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
                    isKitchen ? 'پیش‌نمایش فاکتور آشپزخانه' : 'پیش‌نمایش فاکتور مشتری',
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
                                'نام رستوران',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              Text(
                                'تهران، خیابان اصلی، پلاک ۱۲۳',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'تلفن: ۰۲۱-۱۲۳۴۵۶۷۸',
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
                        _buildReceiptRow('شماره سفارش:', '#${order.id.substring(0, 8).toUpperCase()}'),
                        _buildReceiptRow('تاریخ:', _dateFormatter.format(order.createdAt.toLocal())),
                        _buildReceiptRow('مشتری:', order.customerName),
                        if (order.customerPhone.isNotEmpty)
                          _buildReceiptRow('تلفن:', order.customerPhone),
                        _buildReceiptRow('نوع:', order.orderType == 'delivery' ? 'ارسال به مقصد' : 'تحویل حضوری'),

                        if (order.adminNote != null && order.adminNote!.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSizes.xs),
                            color: Colors.red[50],
                            child: Text(
                              'یادداشت: ${order.adminNote}',
                              style: TextStyle(fontSize: 12, color: Colors.red[800], fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],

                        _dashedDivider(),
                        
                        // Items
                        if (isKitchen) ...[
                          Text('*** کپی آشپزخانه ***', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                          const SizedBox(height: AppSizes.sm),
                        ] else ...[
                          Text('اقلام سفارش', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
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
                                    padding: const EdgeInsets.only(right: 20.0, top: 2.0),
                                    child: Text(
                                      '- ${item.note}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                        _dashedDivider(),

                        // Summary
                        if (!isKitchen) ...[
                          _buildReceiptRow('جمع کل:', '${_currencyFormatter.format(order.totalAmount)} ت'),
                          _dashedDivider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('مبلغ نهایی:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${_currencyFormatter.format(order.totalAmount)} ت', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ] else ...[
                          Center(
                            child: Text(
                              'زمان آماده‌سازی: ${_dateFormatter.format(order.createdAt.toLocal())}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                          ),
                        ],

                        const SizedBox(height: AppSizes.md),
                        Center(
                          child: Text(
                            'با تشکر از انتخاب شما!',
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
                    label: 'بستن',
                    type: AppButtonType.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSizes.md),
                  AppButton(
                    label: 'چاپ فاکتور',
                    icon: Icons.print_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('دستور چاپ به پرینتر ارسال شد.'),
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
              textAlign: TextAlign.left,
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
  const DashedLinePainter();

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