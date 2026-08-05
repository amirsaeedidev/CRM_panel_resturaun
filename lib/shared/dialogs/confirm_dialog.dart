import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_button.dart';
import '../widgets/app_dialog.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = AppStrings.confirm,
    this.cancelText = AppStrings.cancel,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = AppStrings.confirm,
    String cancelText = AppStrings.cancel,
    required VoidCallback onConfirm,
  }) {
    return AppDialog.show(
      context: context,
      title: title,
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.getSecondaryText(context),
            ),
      ),
      actions: [
        AppButton(
          label: cancelText,
          type: AppButtonType.outline,
          width: 120,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSizes.sm),
        AppButton(
          label: confirmText,
          width: 120,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is intended to be used via the static show method.
    return const SizedBox.shrink();
  }
}