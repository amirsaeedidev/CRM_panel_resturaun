import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'صفحه $currentPage از $totalPages',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.getSecondaryText(context),
          ),
        ),
        Row(
          children: [
            _buildButton(
              context: context,
              icon: Icons.chevron_right_rounded,
              onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
            const SizedBox(width: AppSizes.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Text(
                '$currentPage',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            _buildButton(
              context: context,
              icon: Icons.chevron_left_rounded,
              onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.xs),
        decoration: BoxDecoration(
          color: isDisabled 
              ? AppColors.getBorder(context).withOpacity(0.3)
              : AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(color: AppColors.getBorder(context), width: 1),
        ),
        child: Icon(
          icon,
          size: AppSizes.iconSm,
          color: isDisabled 
              ? AppColors.getSecondaryText(context).withOpacity(0.5)
              : AppColors.getPrimaryText(context),
        ),
      ),
    );
  }
}