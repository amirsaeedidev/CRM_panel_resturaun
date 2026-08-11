import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool isExpanded;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: isExpanded,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.getPrimaryText(context),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.getSecondaryText(context),
        ),
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.getSecondaryText(context).withOpacity(0.6),
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: AppColors.getBackground(context),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: AppColors.getBorder(context), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: AppColors.getBorder(context), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dropdownColor: AppColors.getSurface(context),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.getSecondaryText(context),
      ),
      borderRadius: BorderRadius.circular(AppRadius.medium),
    );
  }
}