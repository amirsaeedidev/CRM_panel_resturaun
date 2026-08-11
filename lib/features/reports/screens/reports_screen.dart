import 'package:crm_panel/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../models/report_model.dart';
import '../../../providers/reports_provider.dart';
import '../../../shared/widgets/empty_widget.dart';
import '../../../shared/widgets/error_widget.dart' as app_error;

enum DateRangeFilter { today, thisWeek, thisMonth, custom }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateRangeFilter _selectedFilter = DateRangeFilter.thisMonth;
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReport();
    });
  }

  void _fetchReport() {
    // final provider = context.read<ReportsProvider>();
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_selectedFilter) {
      case DateRangeFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case DateRangeFilter.thisWeek:
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case DateRangeFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case DateRangeFilter.custom:
        if (_customDateRange == null) return;
        startDate = _customDateRange!.start;
        endDate = _customDateRange!.end;
        break;
    }
    
    // provider.fetchSalesReport(startDate: startDate, endDate: endDate);
  }

  Future<void> _pickCustomRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedFilter = DateRangeFilter.custom;
      });
      _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Reports & Analytics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getPrimaryText(context),
                ),
          ),
          const SizedBox(height: AppSizes.lg),

          // Date Filter Chips
          _buildDateFilters(),
          const SizedBox(height: AppSizes.lg),

          // Content - Using dummy state for structure. Replace with Selector<ReportsProvider, ReportModel>
          _buildReportContent(context),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Wrap(
      spacing: AppSizes.sm,
      children: [
        _buildFilterChip('Today', DateRangeFilter.today),
        _buildFilterChip('This Week', DateRangeFilter.thisWeek),
        _buildFilterChip('This Month', DateRangeFilter.thisMonth),
        ActionChip(
          label: Text(
            _customDateRange != null 
                ? 'Custom: ${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                : 'Custom Range',
            style: TextStyle(
              color: _selectedFilter == DateRangeFilter.custom ? Colors.white : AppColors.getPrimaryText(context),
            ),
          ),
          backgroundColor: _selectedFilter == DateRangeFilter.custom ? AppColors.primary : AppColors.getSurface(context),
          onPressed: _pickCustomRange,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, DateRangeFilter filter) {
    bool isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.getPrimaryText(context),
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filter);
          _fetchReport();
        }
      },
    );
  }

  // Dummy state for UI structure
  Widget _buildReportContent(BuildContext context) {
    final bool isLoading = false; // provider.isLoading
    final String? error = null; // provider.error
    final ReportModel? report = null; // provider.report
    final List<Map<String, dynamic>> topProducts = []; // provider.topProducts

    if (isLoading) {
      return const Center(child: AppLoading(size: 40));
    }

    if (error != null) {
      return app_error.AppErrorWidget(
        message: error,
        onRetry: _fetchReport,
      );
    }

    if (report == null && topProducts.isEmpty) {
      return const EmptyWidget(
        title: 'No Data Available',
        message: 'Select a date range to view reports.',
        icon: Icons.bar_chart_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Cards
        LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            return Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(child: _buildSummaryCard(context, 'Delivery Revenue', '15,200,000 T', AppColors.primary)),
                SizedBox(width: isMobile ? 0 : AppSizes.md, height: isMobile ? AppSizes.md : 0),
                Expanded(child: _buildSummaryCard(context, 'Dine In Revenue', '8,500,000 T', AppColors.secondary)),
                SizedBox(width: isMobile ? 0 : AppSizes.md, height: isMobile ? AppSizes.md : 0),
                Expanded(child: _buildSummaryCard(context, 'Total Discounts Given', '1,200,000 T', AppColors.error)),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.lg),

        // Revenue Pie Chart
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revenue Distribution',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: AppColors.primary,
                        value: 64,
                        title: '64%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      PieChartSectionData(
                        color: AppColors.secondary,
                        value: 36,
                        title: '36%',
                        radius: 50,
                        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(context, AppColors.primary, 'Delivery'),
                  const SizedBox(width: AppSizes.lg),
                  _buildLegend(context, AppColors.secondary, 'Dine In'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.lg),

        // Top 10 Best Sellers
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top 10 Best Sellers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(height: AppSizes.lg),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topProducts.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final product = topProducts[index];
                  return _buildTopProductRow(context, product);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Icon(Icons.attach_money, color: color),
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
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: AppSizes.xs),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTopProductRow(BuildContext context, Map<String, dynamic> product) {
    // Dummy structure
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            color: AppColors.getBackground(context),
            child: Icon(Icons.fastfood, color: AppColors.getSecondaryText(context)),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('${product['sold'] ?? 120} units sold', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.getSecondaryText(context))),
              ],
            ),
          ),
          Text(
            '${product['revenue'] ?? '1,500,000'} T',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}