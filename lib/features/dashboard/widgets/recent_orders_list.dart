import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_chip.dart';

class RecentOrdersList extends StatelessWidget {
  const RecentOrdersList({super.key});

  // Mock Data
  final List<Map<String, dynamic>> _orders = const [
    {'id': '#10234', 'customer': 'علی رضایی', 'amount': '1,500,000 تومان', 'status': 'در حال پردازش', 'chipType': ChipType.warning},
    {'id': '#10233', 'customer': 'سارا محمدی', 'amount': '850,000 تومان', 'status': 'تحویل شده', 'chipType': ChipType.success},
    {'id': '#10232', 'customer': 'حسین کریمی', 'amount': '2,300,000 تومان', 'status': 'لغو شده', 'chipType': ChipType.error},
    {'id': '#10231', 'customer': 'مریم احمدی', 'amount': '500,000 تومان', 'status': 'در حال پردازش', 'chipType': ChipType.warning},
    {'id': '#10230', 'customer': 'رضا قاسمی', 'amount': '3,100,000 تومان', 'status': 'تحویل شده', 'chipType': ChipType.success},
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخرین سفارشات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Orders List Screen
                  context.go(AppRoutes.orders);
                },
                child: Text(
                  'مشاهده همه',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          
          // Fixed height Stack to allow the fade effect at the bottom
          SizedBox(
            height: 300, // Adjust height as needed
            child: Stack(
              children: [
                ListView.separated(
                  itemCount: _orders.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.getBorder(context).withOpacity(0.5),
                  ),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.getBackground(context),
                            child: Text(
                              order['customer'][0],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['customer'],
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.getPrimaryText(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'سفارش ${order['id']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.getSecondaryText(context),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                order['amount'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.getPrimaryText(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              CustomChip(
                                label: order['status'],
                                type: order['chipType'],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                // Bottom Blur/Fade Effect
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 40, // Height of the fade effect
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.getSurface(context).withOpacity(0),
                          AppColors.getSurface(context),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}