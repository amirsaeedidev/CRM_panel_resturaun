import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
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

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case DateRangeFilter.today:
        return (DateTime(now.year, now.month, now.day), now);
      case DateRangeFilter.thisWeek:
        return (now.subtract(Duration(days: now.weekday - 1)), now);
      case DateRangeFilter.thisMonth:
        return (DateTime(now.year, now.month, 1), now);
      case DateRangeFilter.custom:
        if (_customDateRange == null) return (DateTime(now.year, now.month, 1), now);
        return (_customDateRange!.start, _customDateRange!.end);
    }
  }

  void _fetchReport() {
    final provider = context.read<ReportsProvider>();
    final (startDate, endDate) = _getDateRange();
    provider.fetchSalesReport(startDate: startDate, endDate: endDate);
    provider.fetchTopProductsReport();
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

    // Fixed: Check if mounted before using context or setState after async gap
    if (!mounted) return;

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
          Text(
            'گزارش‌ها و آمار',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.getPrimaryText(context),
                ),
          ),
          const SizedBox(height: AppSizes.lg),

          _buildDateFilters(),
          const SizedBox(height: AppSizes.lg),

          Consumer<ReportsProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.salesReport == null) {
                return const Center(child: AppLoading(size: 40));
              }

              if (provider.error != null && provider.salesReport == null) {
                return app_error.AppErrorWidget(
                  message: provider.error!,
                  onRetry: _fetchReport,
                );
              }

              final report = provider.salesReport;
              final topProducts = provider.topProductsReport?.chartData ?? [];

              if (report == null && topProducts.isEmpty) {
                return const EmptyWidget(
                  title: 'داده‌ای موجود نیست',
                  message: 'برای مشاهده گزارش‌ها یک بازه زمانی انتخاب کنید.',
                  icon: Icons.bar_chart_outlined,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      return Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        children: [
                          Expanded(child: _buildSummaryCard(context, 'درآمد ارسال', '۱۵,۲۰۰,۰۰۰ ت', AppColors.primary)),
                          SizedBox(width: isMobile ? 0 : AppSizes.md, height: isMobile ? AppSizes.md : 0),
                          Expanded(child: _buildSummaryCard(context, 'درآمد سالن', '۸,۵۰۰,۰۰۰ ت', AppColors.secondary)),
                          SizedBox(width: isMobile ? 0 : AppSizes.md, height: isMobile ? AppSizes.md : 0),
                          Expanded(child: _buildSummaryCard(context, 'مجموع تخفیف‌ها', '۱,۲۰۰,۰۰۰ ت', AppColors.error)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),

                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'توزیع درآمد',
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
                                  title: '۶۴٪',
                                  radius: 50,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                PieChartSectionData(
                                  color: AppColors.secondary,
                                  value: 36,
                                  title: '۳۶٪',
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
                            _buildLegend(context, AppColors.primary, 'ارسال'),
                            const SizedBox(width: AppSizes.lg),
                            _buildLegend(context, AppColors.secondary, 'سالن'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '۱۰ محصول پرفروش',
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
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilters() {
    return Wrap(
      spacing: AppSizes.sm,
      children: [
        _buildFilterChip('امروز', DateRangeFilter.today),
        _buildFilterChip('این هفته', DateRangeFilter.thisWeek),
        _buildFilterChip('این ماه', DateRangeFilter.thisMonth),
        ActionChip(
          label: Text(
            _customDateRange != null 
                ? 'دلخواه: ${_customDateRange!.start.day}/${_customDateRange!.start.month} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}'
                : 'بازه دلخواه',
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

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
                Text('نام محصول', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('${product['sold'] ?? 120} عدد فروخته شد', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.getSecondaryText(context))),
              ],
            ),
          ),
          Text(
            '${product['revenue'] ?? '۱,۵۰۰,۰۰۰'} ت',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}