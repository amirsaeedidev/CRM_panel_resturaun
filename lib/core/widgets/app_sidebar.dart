import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../constants/app_routes.dart';
import '../theme/app_typography.dart';
import 'navigation_item.dart';
import '../../providers/navigation_provider.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();

    return Container(
      width: AppSizes.sidebarWidth,
      color: AppColors.surfaceDark,
      child: Column(
        children: [
          // Logo Header
          Container(
            height: AppSizes.topBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard, color: AppColors.primary, size: AppSizes.iconLg),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.appName,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.borderDark, height: 1),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.md,
                horizontal: AppSizes.sm,
              ),
              children: [
                NavigationItem(
                  icon: Icons.home_outlined,
                  label: AppStrings.dashboard,
                  isActive: navProvider.selectedIndex == 0,
                  onTap: () {
                    navProvider.updateIndex(0);
                    context.go(AppRoutes.dashboard);
                  },
                ),
                NavigationItem(
                  icon: Icons.shopping_bag_outlined,
                  label: AppStrings.orders,
                  isActive: navProvider.selectedIndex == 1,
                  onTap: () {
                    navProvider.updateIndex(1);
                    context.go(AppRoutes.orders);
                  },
                ),
                NavigationItem(
                  icon: Icons.inventory_2_outlined,
                  label: AppStrings.products,
                  isActive: navProvider.selectedIndex == 2,
                  onTap: () {
                    navProvider.updateIndex(2);
                    context.go(AppRoutes.products);
                  },
                ),
                NavigationItem(
                  icon: Icons.people_outline,
                  label: AppStrings.customers,
                  isActive: navProvider.selectedIndex == 3,
                  onTap: () {
                    navProvider.updateIndex(3);
                    context.go(AppRoutes.customers);
                  },
                ),
                NavigationItem(
                  icon: Icons.category_outlined,
                  label: AppStrings.categories,
                  isActive: navProvider.selectedIndex == 4,
                  onTap: () {
                    navProvider.updateIndex(4);
                    context.go(AppRoutes.categories);
                  },
                ),
                NavigationItem(
                  icon: Icons.bar_chart,
                  label: AppStrings.reports,
                  isActive: navProvider.selectedIndex == 5,
                  onTap: () {
                    navProvider.updateIndex(5);
                    context.go(AppRoutes.reports);
                  },
                ),
                NavigationItem(
                  icon: Icons.settings_outlined,
                  label: AppStrings.settings,
                  isActive: navProvider.selectedIndex == 6,
                  onTap: () {
                    navProvider.updateIndex(6);
                    context.go(AppRoutes.settings);
                  },
                ),
              ],
            ),
          ),
          
          // Footer User Info
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderDark, width: 1)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryDark),
                      ),
                      Text(
                        'admin@crm.com',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: AppColors.textSecondaryDark, size: AppSizes.iconSm),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}