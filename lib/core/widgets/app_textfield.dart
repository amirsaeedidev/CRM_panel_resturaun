import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? errorText;
  final int? maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization; // Added
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none, // Added
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization, // Added
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      onTap: onTap,
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
        suffixIcon: suffixIcon,
        errorText: errorText,
        errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.error),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}