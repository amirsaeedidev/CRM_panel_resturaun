import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;
import '../../../providers/dashboard_provider.dart';
import '../widgets/statistic_card.dart';
import '../widgets/restaurant_sales_chart.dart'; // Replaced with custom chart
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
          final contentWidth = constraints.maxWidth;

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
                    'سلام، خوش آمدی!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  Text(
                    'در اینجا خلاصه عملکرد فروشگاه شما در ۳۰ روز گذشته آمده است.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getSecondaryText(context),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // کارت‌های آماری واکنش‌گرا
                  Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.md,
                    children: [
                      _buildStatCard(
                        width: cardWidth,
                        title: 'فروش کل',
                        value: stats != null
                            ? '${stats.totalSales.toStringAsFixed(0)} تومان'
                            : 'ناموجود',
                        icon: Icons.attach_money,
                        iconColor: AppColors.success,
                        changePercentage: stats != null
                            ? stats.salesGrowthPercentage.toStringAsFixed(1)
                            : '0',
                      ),
                      _buildStatCard(
                        width: cardWidth,
                        title: 'سفارشات جدید',
                        value: stats != null
                            ? stats.totalOrders.toString()
                            : 'ناموجود',
                        icon: Icons.shopping_cart_checkout,
                        iconColor: AppColors.primary,
                        changePercentage: stats != null
                            ? stats.ordersGrowthPercentage.toStringAsFixed(1)
                            : '0',
                      ),
                      _buildStatCard(
                        width: cardWidth,
                        title: 'کاربران فعال',
                        value: stats != null
                            ? stats.totalCustomers.toString()
                            : 'ناموجود',
                        icon: Icons.people_alt_outlined,
                        iconColor: AppColors.accent,
                        changePercentage: stats != null
                            ? stats.customersGrowthPercentage.toStringAsFixed(1)
                            : '0',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // نمودارهای واکنش‌گرا
                  if (stackCharts) ...[
                    const SizedBox(width: double.infinity, child: RestaurantSalesChart()),
                    const SizedBox(height: AppSizes.md),
                    const SizedBox(
                      width: double.infinity,
                      child: CategoryPieChart(),
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(flex: 2, child: RestaurantSalesChart()),
                        SizedBox(width: AppSizes.md),
                        Expanded(flex: 1, child: CategoryPieChart()),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSizes.lg),

                  // آخرین سفارشات
                  Text(
                    'آخرین سفارشات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

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
                      title: 'سفارش اخیری وجود ندارد',
                      message: 'هیچ سفارش اخیری برای نمایش وجود ندارد.',
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