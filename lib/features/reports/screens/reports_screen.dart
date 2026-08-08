import 'package:crm_panel/core/theme/app_radius.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_table.dart';
import '../../../core/widgets/custom_chip.dart';
import '../../../shared/widgets/pagination_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _currentPage = 1;
  final int _totalPages = 3;

  // Mock Data for Top Products
  final List<Map<String, dynamic>> _topProducts = [
    {'name': 'گوشی موبایل سامسونگ A52', 'sold': 120, 'revenue': '1,500,000,000', 'trend': 'رشد 12%'},
    {'name': 'لپ‌تاپ ایسوس Zenbook', 'sold': 45, 'revenue': '2,025,000,000', 'trend': 'رشد 5%'},
    {'name': 'پیراهن مردانه یقه اسکی', 'sold': 320, 'revenue': '272,000,000', 'trend': 'افت 3%'},
    {'name': 'هدفون بلوتوثی جی‌بی‌ال', 'sold': 85, 'revenue': '272,000,000', 'trend': 'رشد 8%'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'گزارش‌ها و آمار',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.getPrimaryText(context),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              AppButton(
                label: 'خروجی اکسل',
                icon: Icons.file_download_outlined,
                type: AppButtonType.secondary,
                width: 150,
                onPressed: () {
                  // TODO: Implement Export Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('در حال آماده‌سازی فایل اکسل...'), backgroundColor: AppColors.info),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Summary Cards (Mini Stats)
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.md,
            children: [
              _buildMiniStatCard(context, title: 'فروش کل امسال', value: '4.5 میلیارد تومان', icon: Icons.attach_money, color: AppColors.success),
              _buildMiniStatCard(context, title: 'تعداد سفارشات', value: '1,245', icon: Icons.shopping_cart_checkout, color: AppColors.primary),
              _buildMiniStatCard(context, title: 'مشتریان جدید', value: '320 نفر', icon: Icons.person_add_alt_1, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // Charts Section
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 768;
              return Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(flex: isMobile ? 1 : 2, child: _buildSalesBarChart(context)),
                  SizedBox(width: isMobile ? 0 : AppSizes.md, height: isMobile ? AppSizes.md : 0),
                  Expanded(flex: isMobile ? 1 : 1, child: _buildCustomerPieChart(context)),
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.lg),

          // Top Products Table
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Text(
                        'پرفروش‌ترین محصولات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.getPrimaryText(context),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                AppTable(
                  minWidth: 700,
                  headers: const ['محصول', 'تعداد فروش', 'درآمد (تومان)', 'روند'],
                  rows: _topProducts.map((prod) {
                    return [
                      Text(prod['name'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context), fontWeight: FontWeight.bold)),
                      Text(prod['sold'].toString(), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getSecondaryText(context))),
                      Text(prod['revenue'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.getPrimaryText(context))),
                      CustomChip(
                        label: prod['trend'],
                        type: prod['trend'].toString().contains('رشد') ? ChipType.success : ChipType.error,
                      ),
                    ];
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: PaginationWidget(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return SizedBox(
      width: 250,
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconLg),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.getSecondaryText(context),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.getPrimaryText(context),
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesBarChart(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فروش ماهانه (میلیون تومان)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.getPrimaryText(context),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(months[value.toInt()], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.getSecondaryText(context))),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _buildBarGroup(context, 0, 120, AppColors.primary),
                  _buildBarGroup(context, 1, 90, AppColors.primary),
                  _buildBarGroup(context, 2, 150, AppColors.primary),
                  _buildBarGroup(context, 3, 80, AppColors.primary),
                  _buildBarGroup(context, 4, 200, AppColors.secondary),
                  _buildBarGroup(context, 5, 170, AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(BuildContext context, int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerPieChart(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزیع مشتریان',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.getPrimaryText(context),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.xl),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: AppColors.primary, value: 60, title: 'وفادار (60%)', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: AppColors.secondary, value: 25, title: 'عادی (25%)', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: AppColors.accent, value: 15, title: 'جدید (15%)', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}