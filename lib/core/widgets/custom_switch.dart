import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_radius.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? Colors.white,
      activeTrackColor: activeColor?.withOpacity(0.8) ?? AppColors.primary,
      inactiveThumbColor: AppColors.getPrimaryText(context),
      inactiveTrackColor: AppColors.getBorder(context),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      thumbIcon: WidgetStateProperty.all(
        const Icon(Icons.check, size: AppSizes.iconXs, color: Colors.white),
      ),
    );
  }
}