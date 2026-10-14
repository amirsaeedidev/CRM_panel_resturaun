import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_loading.dart';
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
      if (!mounted) return;

      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // This width already accounts for the horizontal padding above.
          final contentWidth = constraints.maxWidth;

          // Adapt card columns to the actual available content width.
          final int cardColumns;
          if (contentWidth >= 1050) {
            cardColumns = 3;
          } else if (contentWidth >= 620) {
            cardColumns = 2;
          } else {
            cardColumns = 1;
          }

          final cardWidth =
              (contentWidth - AppSizes.md * (cardColumns - 1)) / cardColumns;

          // Stack charts before they become cramped.
          final stackCharts = contentWidth < 900;

          return Consumer<DashboardProvider>(
            builder: (context, provider, child) {
              final stats = provider.statistics;

              if (provider.isLoading && stats == null) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: AppLoading()),
                );
              }

              // This is a real data-loading error, not a layout placeholder.
              if (provider.error != null && stats == null) {
                return app_error.AppErrorWidget(
                  message: provider.error!,
                  onRetry: () => provider.fetchDashboardData(),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  Text(
                    'Here is a summary of your store performance '
                    'over the last 30 days.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getSecondaryText(context),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Responsive statistic cards.
                  Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.md,
                    children: [
                      _buildStatCard(
                        width: cardWidth,
                        title: 'Total Sales',
                        value: stats != null
                            ? '${stats.totalSales.toStringAsFixed(0)} T'
                            : 'N/A',
                        icon: Icons.attach_money,
                        iconColor: AppColors.success,
                        changePercentage: stats != null
                            ? stats.salesGrowthPercentage.toStringAsFixed(1)
                            : '0',
                      ),
                      _buildStatCard(
                        width: cardWidth,
                        title: 'New Orders',
                        value: stats != null
                            ? stats.totalOrders.toString()
                            : 'N/A',
                        icon: Icons.shopping_cart_checkout,
                        iconColor: AppColors.primary,
                        changePercentage: stats != null
                            ? stats.ordersGrowthPercentage.toStringAsFixed(1)
                            : '0',
                      ),
                      _buildStatCard(
                        width: cardWidth,
                        title: 'Active Users',
                        value: stats != null
                            ? stats.totalCustomers.toString()
                            : 'N/A',
                        icon: Icons.people_alt_outlined,
                        iconColor: AppColors.accent,
                        changePercentage: stats != null
                            ? stats.customersGrowthPercentage.toStringAsFixed(1)
                            : '0',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Responsive charts.
                  if (stackCharts) ...[
                    const SizedBox(width: double.infinity, child: SalesChart()),
                    const SizedBox(height: AppSizes.md),
                    const SizedBox(
                      width: double.infinity,
                      child: CategoryPieChart(),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(flex: 2, child: SalesChart()),
                        SizedBox(width: AppSizes.md),
                        Expanded(flex: 1, child: CategoryPieChart()),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSizes.lg),

                  // Recent orders.
                  Text(
                    'Recent Orders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Recent Orders List
                  if (provider.recentOrdersError != null &&
                      provider.recentOrders.isEmpty &&
                      !provider.isLoading)
                    app_error.AppErrorWidget(
                      message: provider.recentOrdersError!,
                      onRetry: () => provider.fetchDashboardData(),
                    )
                  else if (provider.recentOrders.isEmpty && provider.isLoading)
                    const SizedBox(
                      height: 120,
                      child: Center(child: AppLoading()),
                    )
                  else if (provider.recentOrders.isEmpty)
                    const EmptyWidget(
                      title: 'No Recent Orders',
                      message: 'There are no recent orders to display.',
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    const RecentOrdersList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
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
