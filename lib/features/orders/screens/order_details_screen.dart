import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_chip.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  // Mock Data
  Map<String, dynamic> get _order => {
        'id': '#10234',
        'customer': 'علی رضایی',
        'phone': '09123456789',
        'address': 'تهران، خیابان ولیعصر، کوچه ۱۲، پلاک ۴',
        'date': '1403/08/12',
        'total': '1,500,000 تومان',
        'shipping': '50,000 تومان',
        'status': 'ارسال شده',
      };

  final List<Map<String, dynamic>> _items = const [
    {'name': 'گوشی موبایل سامسونگ A52', 'qty': 1, 'price': '12,500,000'},
    {'name': 'کاور گوشی', 'qty': 2, 'price': '150,000'},
  ];

  final List<Map<String, dynamic>> _timeline = const [
    {'title': 'ثبت سفارش', 'date': '1403/08/12 - 10:30', 'isDone': true},
    {'title': 'پرداخت تایید شد', 'date': '1403/08/12 - 10:35', 'isDone': true},
    {'title': 'آماده‌سازی در انبار', 'date': '1403/08/12 - 14:00', 'isDone': true},
    {'title': 'ارسال شد', 'date': '1403/08/13 - 09:00', 'isDone': true},
    {'title': 'تحویل به مشتری', 'date': 'در انتظار...', 'isDone': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('جزئیات سفارش'),
        backgroundColor: AppColors.getSurface(context),
        foregroundColor: AppColors.getPrimaryText(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سفارش ${_order['id']}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.getPrimaryText(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                CustomChip(
                  label: _order['status'],
                  type: ChipType.info,
                  icon: Icons.local_shipping_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'تاریخ ثبت: ${_order['date']}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getSecondaryText(context),
                  ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Customer & Shipping Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoTitle(context, 'اطلاعات مشتری'),
                        const SizedBox(height: AppSizes.sm),
                        _buildInfoRow(context, Icons.person_outline, _order['customer']),
                        _buildInfoRow(context, Icons.phone_outlined, _order['phone']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoTitle(context, 'آدرس ارسال'),
                        const SizedBox(height: AppSizes.sm),
                        _buildInfoRow(context, Icons.location_on_outlined, _order['address']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Order Items
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoTitle(context, 'محصولات سفارش'),
                  const Divider(height: AppSizes.lg),
                  ..._items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getPrimaryText(context),
                                    ),
                              ),
                            ),
                            Text(
                              '${item['qty']} عدد',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.getSecondaryText(context),
                                  ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            SizedBox(
                              width: 100,
                              child: Text(
                                '${item['price']} ت',
                                textAlign: TextAlign.end,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getPrimaryText(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: AppSizes.lg),
                  _buildPriceRow(context, 'هزینه ارسال', _order['shipping']),
                  const SizedBox(height: AppSizes.sm),
                  _buildPriceRow(context, 'مبلغ کل قابل پرداخت', _order['total'], isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Timeline
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoTitle(context, 'وضعیت سفارش'),
                  const SizedBox(height: AppSizes.lg),
                  ..._timeline.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> item = entry.value;
                    bool isLast = idx == _timeline.length - 1;
                    return _buildTimelineItem(context, item, isLast);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.getPrimaryText(context),
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.getSecondaryText(context)),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getPrimaryText(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.getPrimaryText(context), fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context)),
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context)),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> item, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item['isDone'] ? AppColors.success : AppColors.getBorder(context),
                shape: BoxShape.circle,
              ),
              child: item['isDone']
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : const SizedBox.shrink(),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.getBorder(context),
              ),
          ],
        ),
        const SizedBox(width: AppSizes.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: item['isDone'] ? AppColors.getPrimaryText(context) : AppColors.getSecondaryText(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              item['date'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.getSecondaryText(context),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}