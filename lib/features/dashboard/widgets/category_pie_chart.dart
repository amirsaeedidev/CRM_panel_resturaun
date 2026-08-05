import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزیع دسته‌بندی‌ها',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.getPrimaryText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'میزان فروش بر اساس دسته‌بندی',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.getSecondaryText(context),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: AppColors.primary,
                    value: 40,
                    title: '40%',
                    radius: 50,
                    titleStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: AppColors.secondary,
                    value: 30,
                    title: '30%',
                    radius: 50,
                    titleStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: AppColors.accent,
                    value: 20,
                    title: '20%',
                    radius: 50,
                    titleStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    color: AppColors.success,
                    value: 10,
                    title: '10%',
                    radius: 50,
                    titleStyle: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          // Legend
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.sm,
            children: [
              _buildLegend(context, color: AppColors.primary, label: 'الکترونیک'),
              _buildLegend(context, color: AppColors.secondary, label: 'پوشاک'),
              _buildLegend(context, color: AppColors.accent, label: 'غذا'),
              _buildLegend(context, color: AppColors.success, label: 'سایر'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: AppSizes.xs),
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.getSecondaryText(context)),
        ),
      ],
    );
  }
}