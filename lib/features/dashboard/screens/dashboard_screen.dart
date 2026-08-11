import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/statistic_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/customer_activity_feed.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we are on a mobile device
        final isMobile = constraints.maxWidth < 768;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Greeting
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Here is a summary of your store performance over the last 30 days.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getSecondaryText(context),
                    ),
              ),
              const SizedBox(height: AppSizes.lg),

              // Statistics Cards
              Wrap(
                spacing: AppSizes.md,
                runSpacing: AppSizes.md,
                children: [
                  _buildStatCard(
                    context: context,
                    width: isMobile ? constraints.maxWidth : (constraints.maxWidth - AppSizes.md * 2) / 3,
                    title: 'Total Sales',
                    value: '45,200,000 T',
                    icon: Icons.attach_money,
                    iconColor: AppColors.success,
                    changePercentage: '12',
                  ),
                  _buildStatCard(
                    context: context,
                    width: isMobile ? constraints.maxWidth : (constraints.maxWidth - AppSizes.md * 2) / 3,
                    title: 'New Orders',
                    value: '124',
                    icon: Icons.shopping_cart_checkout,
                    iconColor: AppColors.primary,
                    changePercentage: '8',
                  ),
                  _buildStatCard(
                    context: context,
                    width: isMobile ? constraints.maxWidth : (constraints.maxWidth - AppSizes.md * 2) / 3,
                    title: 'Active Users',
                    value: '3,450',
                    icon: Icons.people_alt_outlined,
                    iconColor: AppColors.accent,
                    changePercentage: '5',
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // Charts Section (Fixed for Mobile ScrollView)
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(
                      width: double.infinity, // Take full width
                      child: SalesChart(),
                    ),
                    SizedBox(height: AppSizes.md),
                    SizedBox(
                      width: double.infinity,
                      child: CategoryPieChart(),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Expanded(flex: 2, child: SalesChart()),
                    SizedBox(width: AppSizes.md),
                    Expanded(flex: 1, child: CategoryPieChart()),
                  ],
                ),
              const SizedBox(height: AppSizes.lg),

              // Recent Orders List
              const RecentOrdersList(),
              const SizedBox(height: AppSizes.lg),

              // Customer Activity Feed (From Prompt 11)
              const CustomerActivityFeed(
                activities: [], // Empty until DashboardProvider is connected
                isLoading: false,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String changePercentage,
  }) {
    return SizedBox(
      width: width,
      child: StatisticCard(
        title: title,
        value: value,
        icon: icon,
        iconColor: iconColor,
        changePercentage: changePercentage,
      ),
    );
  }
}