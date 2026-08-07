import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String changePercentage;
  final bool isPositiveChange;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.changePercentage,
    this.isPositiveChange = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositiveChange ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositiveChange ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$changePercentage%',
                      style: AppTypography.labelSmall.copyWith(
                        color: isPositiveChange ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.getPrimaryText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.getSecondaryText(context),
            ),
          ),
        ],
      ),
    );
  }
}