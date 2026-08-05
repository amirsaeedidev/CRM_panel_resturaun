import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum ChipType { primary, success, warning, error, info, neutral }

class CustomChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final IconData? icon;
  final VoidCallback? onDeleted;

  const CustomChip({
    super.key,
    required this.label,
    this.type = ChipType.neutral,
    this.icon,
    this.onDeleted,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case ChipType.primary: return AppColors.primary.withOpacity(0.1);
      case ChipType.success: return AppColors.success.withOpacity(0.1);
      case ChipType.warning: return AppColors.warning.withOpacity(0.1);
      case ChipType.error: return AppColors.error.withOpacity(0.1);
      case ChipType.info: return AppColors.info.withOpacity(0.1);
      case ChipType.neutral: return AppColors.borderLight.withOpacity(0.5);
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case ChipType.primary: return AppColors.primary;
      case ChipType.success: return AppColors.success;
      case ChipType.warning: return AppColors.warning;
      case ChipType.error: return AppColors.error;
      case ChipType.info: return AppColors.info;
      case ChipType.neutral: return AppColors.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppRadius.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconXs, color: _getForegroundColor()),
            const SizedBox(width: AppSizes.xs),
          ],
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: _getForegroundColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: AppSizes.xs),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(Icons.close, size: AppSizes.iconXs, color: _getForegroundColor()),
            ),
          ],
        ],
      ),
    );
  }
}