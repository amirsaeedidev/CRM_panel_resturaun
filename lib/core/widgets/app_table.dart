import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class AppTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;
  final double? minWidth;

  const AppTable({
    super.key,
    required this.headers,
    required this.rows,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row (Scrolls horizontally with the body)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: minWidth ?? MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.getBackground(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.medium),
                topRight: Radius.circular(AppRadius.medium),
              ),
            ),
            child: Row(
              children: headers.map((h) => Expanded(
                child: Text(
                  h,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.getSecondaryText(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
        
        // Data Rows (Scrolls both horizontally and vertically)
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: minWidth ?? MediaQuery.sizeOf(context).width,
              child: ListView.separated(
                itemCount: rows.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppColors.getBorder(context),
                ),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.md,
                    ),
                    color: AppColors.getSurface(context),
                    child: Row(
                      children: rows[index].map((cell) => Expanded(child: cell)).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}