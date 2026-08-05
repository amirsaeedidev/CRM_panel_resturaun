import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_typography.dart';
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
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.getPrimaryText(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'مشاهده همه',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                        style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['customer'],
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.getPrimaryText(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'سفارش ${order['id']}',
                            style: AppTypography.bodySmall.copyWith(
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
                          style: AppTypography.bodyMedium.copyWith(
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
        ],
      ),
    );
  }
}