import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_loading.dart';
//import '../../../core/widgets/app_card.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;
import '../../../providers/dashboard_provider.dart';
import '../widgets/statistic_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/recent_orders_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.statistics == null) {
              return const Center(child: AppLoading());
            }

            if (provider.error != null && provider.statistics == null) {
              return app_error.AppErrorWidget(
                message: provider.error!,
                onRetry: () => provider.fetchDashboardData(),
              );
            }

            final stats = provider.statistics;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        value: stats != null ? '${stats.totalSales.toStringAsFixed(0)} T' : 'N/A',
                        icon: Icons.attach_money,
                        iconColor: AppColors.success,
                        changePercentage: stats != null ? stats.salesGrowthPercentage.toStringAsFixed(1) : '0',
                      ),
                      _buildStatCard(
                        context: context,
                        width: isMobile ? constraints.maxWidth : (constraints.maxWidth - AppSizes.md * 2) / 3,
                        title: 'New Orders',
                        value: stats != null ? stats.totalOrders.toString() : 'N/A',
                        icon: Icons.shopping_cart_checkout,
                        iconColor: AppColors.primary,
                        changePercentage: stats != null ? stats.ordersGrowthPercentage.toStringAsFixed(1) : '0',
                      ),
                      _buildStatCard(
                        context: context,
                        width: isMobile ? constraints.maxWidth : (constraints.maxWidth - AppSizes.md * 2) / 3,
                        title: 'Active Users',
                        value: stats != null ? stats.totalCustomers.toString() : 'N/A',
                        icon: Icons.people_alt_outlined,
                        iconColor: AppColors.accent,
                        changePercentage: stats != null ? stats.customersGrowthPercentage.toStringAsFixed(1) : '0',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Charts Section
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(width: double.infinity, child: SalesChart()),
                        SizedBox(height: AppSizes.md),
                        SizedBox(width: double.infinity, child: CategoryPieChart()),
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
                  if (provider.recentOrders.isEmpty && !provider.isLoading)
                    const EmptyWidget(
                      title: 'No Recent Orders',
                      message: 'There are no recent orders to display.',
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    const RecentOrdersList(),
                ],
              ),
            );
          },
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