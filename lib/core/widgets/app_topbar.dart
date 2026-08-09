import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../../providers/theme_provider.dart';

class AppTopbar extends StatelessWidget {
  final String title;
  final VoidCallback onMenuTap;

  const AppTopbar({
    super.key,
    required this.title,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        border: Border(
          bottom: BorderSide(color: AppColors.getBorder(context), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Menu Button (For Mobile/Tablet)
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: onMenuTap,
            color: AppColors.getPrimaryText(context),
          ),
          const SizedBox(width: AppSizes.sm),
          
          // Page Title
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.getPrimaryText(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // Search Field (Responsive)
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.getSecondaryText(context)),
                prefixIcon: Icon(Icons.search, color: AppColors.getSecondaryText(context), size: AppSizes.iconSm),
                filled: true,
                fillColor: AppColors.getBackground(context),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Spacer(flex: 3),
          
          // Action Icons
          IconButton(
            icon: Icon(Icons.notifications_none, color: AppColors.getPrimaryText(context)),
            onPressed: () {},
          ),
          
          // Dark Mode Toggle Button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: AppColors.getPrimaryText(context),
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          
          const SizedBox(width: AppSizes.sm),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: AppSizes.iconSm),
          ),
        ],
      ),
    );
  }
}