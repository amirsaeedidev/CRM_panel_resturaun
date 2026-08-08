import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_chip.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final int customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  // Mock Data
  Map<String, dynamic> get _customer => {
        'name': 'علی رضایی',
        'phone': '09123456789',
        'email': 'ali@example.com',
        'address': 'تهران، خیابان ولیعصر، پلاک ۱۲۳',
        'status': 'فعال',
        'orders': 12,
        'spent': '4,500,000 تومان',
      };

  final List<Map<String, dynamic>> _recentOrders = const [
    {'id': '#10234', 'date': '1403/08/12', 'amount': '1,500,000', 'status': 'تحویل شده'},
    {'id': '#10198', 'date': '1403/08/01', 'amount': '800,000', 'status': 'لغو شده'},
    {'id': '#10112', 'date': '1403/07/15', 'amount': '2,200,000', 'status': 'تحویل شده'},
  ];

  ChipType _getStatusChipType(String status) {
    switch (status) {
      case 'تحویل شده': return ChipType.success;
      case 'در حال پردازش': return ChipType.warning;
      case 'لغو شده': return ChipType.error;
      default: return ChipType.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        title: const Text('جزئیات مشتری'),
        backgroundColor: AppColors.getSurface(context),
        foregroundColor: AppColors.getPrimaryText(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _customer['name'][0],
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _customer['name'],
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.getPrimaryText(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          _customer['email'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.getSecondaryText(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                  CustomChip(
                    label: _customer['status'],
                    type: ChipType.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تعداد سفارشات',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.getSecondaryText(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          _customer['orders'].toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.getPrimaryText(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
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
                        Text(
                          'مجموع خرید',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.getSecondaryText(context),
                              ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          _customer['spent'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),

            // Contact Info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, Icons.phone_outlined, 'شماره تماس', _customer['phone']),
                  const Divider(height: AppSizes.lg),
                  _buildInfoRow(context, Icons.location_on_outlined, 'آدرس', _customer['address']),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Recent Orders
            Text(
              'آخرین سفارش‌ها',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.getPrimaryText(context),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.md),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentOrders.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = _recentOrders[index];
                return AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سفارش ${order['id']}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.getPrimaryText(context),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order['date'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.getSecondaryText(context),
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${order['amount']} تومان',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.getPrimaryText(context),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          CustomChip(
                            label: order['status'],
                            type: _getStatusChipType(order['status']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.getSecondaryText(context), size: 20),
        const SizedBox(width: AppSizes.sm),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.getSecondaryText(context),
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.getPrimaryText(context),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}