import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppSearch extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;
  final bool autoFocus;

  const AppSearch({
    super.key,
    this.controller,
    this.onChanged,
    this.onClear,
    this.hintText = AppStrings.search,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autoFocus,
      style: AppTypography.bodyMedium.copyWith(color: AppColors.getPrimaryText(context)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.getSecondaryText(context)),
        prefixIcon: Icon(Icons.search, color: AppColors.getSecondaryText(context), size: AppSizes.iconSm),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close, color: AppColors.getSecondaryText(context), size: AppSizes.iconSm),
                onPressed: () {
                  controller?.clear();
                  onChanged?.call('');
                  onClear?.call();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.getSurface(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.circular),
          borderSide: BorderSide(color: AppColors.getBorder(context), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.circular),
          borderSide: BorderSide(color: AppColors.getBorder(context), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.circular),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}