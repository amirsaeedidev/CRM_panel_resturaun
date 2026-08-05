import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSizes.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    bool isDisabled = onPressed == null || isLoading;
    
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = isDisabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        foregroundColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case AppButtonType.secondary:
        backgroundColor = isDisabled ? AppColors.secondary.withOpacity(0.5) : AppColors.secondary;
        foregroundColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case AppButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        borderColor = isDisabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        break;
      case AppButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = isDisabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        borderColor = Colors.transparent;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            side: BorderSide(color: borderColor, width: type == AppButtonType.outline ? 1.5 : 0),
          ),
          elevation: type == AppButtonType.text || type == AppButtonType.outline ? 0 : 2,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        ),
        child: isLoading
            ? SpinKitThreeBounce(color: foregroundColor, size: AppSizes.iconMd)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppSizes.iconSm),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(color: foregroundColor),
                  ),
                ],
              ),
      ),
    );
  }
}