import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_button.dart';
import '../widgets/app_dialog.dart';

class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDelete;

  const DeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onDelete,
  }) {
    return AppDialog.show(
      context: context,
      title: title,
      content: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 32),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.getSecondaryText(context),
                  ),
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: AppStrings.cancel,
          type: AppButtonType.outline,
          width: 120,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: AppSizes.sm),
        AppButton(
          label: AppStrings.delete,
          type: AppButtonType.primary,
          width: 120,
          backgroundColor: AppColors.error,
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}