import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/restaurant_analytics_models.dart';
import '../../../providers/restaurant_analytics_provider.dart';

/// ویجت گزارش فروش رستوران؛ می‌توان آن را مستقیماً داخل داشبورد قرار داد.
/// فونت را از ThemeData اپ خودت تنظیم کن؛ این ویجت فونت جداگانه تحمیل نمی‌کند.
class RestaurantSalesChart extends StatefulWidget {
  const RestaurantSalesChart({super.key});

  @override
  State<RestaurantSalesChart> createState() => _RestaurantSalesChartState();
}

class _RestaurantSalesChartState extends State<RestaurantSalesChart> {
  AnalyticsMetric _metric = AnalyticsMetric.orders;

  @override
  void initState() {
    super.initState();
    // گرفتن داده را از build انجام نمی‌دهیم تا در هر بازسازی دوباره درخواست ارسال نشود.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<RestaurantAnalyticsProvider>();
      if (!provider.hasLoaded && !provider.isLoading) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Consumer<RestaurantAnalyticsProvider>(
        builder: (context, provider, _) {
          final buckets = provider.buckets;
          final selected = provider.selectedBucket;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.7)),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.045),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 16),
                _buildControls(context, provider),
                if (provider.isLoading) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(minHeight: 3),
                  ),
                ],
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  _buildError(context, provider),
                ],
                if (selected != null) ...[
                  const SizedBox(height: 18),
                  _buildSelectedDetails(context, selected, provider.supportsFoodBreakdown),
                ],
                const SizedBox(height: 18),
                _buildMetricSelector(context),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final chartHeight = constraints.maxWidth >= 720 ? 300.0 : 250.0;
                    return _AnimatedSalesChart(
                      height: chartHeight,
                      buckets: buckets,
                      metric: _metric,
                      selectedIndex: provider.selectedBucketIndex,
                      color: scheme.primary,
                      textColor: scheme.onSurfaceVariant,
                      gridColor: scheme.outlineVariant,
                      animationKey: '${provider.period.name}_${_metric.name}_${buckets.map((b) => b.start.millisecondsSinceEpoch).join('-')}_${buckets.map((b) => b.valueFor(_metric)).join('-')}',
                      onSelect: provider.selectBucket,
                    );
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(9)),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _metricLegend(_metric),
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const Spacer(),
                    Icon(Icons.touch_app_outlined, size: 15, color: scheme.onSurfaceVariant.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      'برای دیدن جزئیات، ستون را انتخاب کن',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant.withOpacity(0.8)),
                    ),
                  ],
                ),
                if (selected != null) ...[
                  const SizedBox(height: 16),
                  _buildFoodBreakdown(context, selected, provider.supportsFoodBreakdown),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RestaurantAnalyticsProvider provider) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.query_stats_rounded, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('گزارش فروش رستوران', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(
                'سفارش‌ها، غذاهای فروخته‌شده و درآمد',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'به‌روزرسانی گزارش',
          onPressed: provider.isLoading ? null : () => provider.refresh(),
          icon: provider.isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.refresh_rounded),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, RestaurantAnalyticsProvider provider) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _periodChip(context, provider, AnalyticsPeriod.daily, 'روزانه'),
            _periodChip(context, provider, AnalyticsPeriod.weekly, 'هفتگی'),
            _periodChip(context, provider, AnalyticsPeriod.yearly, 'سالانه'),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'بازه قبلی',
                onPressed: provider.isLoading ? null : () => provider.goToPreviousRange(),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 105, maxWidth: 180),
                child: Text(
                  provider.rangeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'بازه بعدی',
                onPressed: provider.isLoading || !provider.canGoNext ? null : () => provider.goToNextRange(),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _periodChip(BuildContext context, RestaurantAnalyticsProvider provider, AnalyticsPeriod period, String label) {
    final selected = provider.period == period;
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: provider.isLoading ? null : (_) => provider.setPeriod(period),
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      selectedColor: scheme.primary,
      backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.45),
      side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant.withOpacity(0.65)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildError(BuildContext context, RestaurantAnalyticsProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: TextStyle(color: scheme.onErrorContainer, fontSize: 12),
            ),
          ),
          TextButton(onPressed: () => provider.refresh(), child: const Text('تلاش دوباره')),
        ],
      ),
    );
  }

  Widget _buildSelectedDetails(BuildContext context, SalesBucket bucket, bool supportsFoodBreakdown) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final averageOrderAmount = bucket.successfulOrders == 0 ? 0.0 : bucket.revenue / bucket.successfulOrders;
    final averageFoodsPerOrder = bucket.successfulOrders == 0 ? 0.0 : bucket.foodsSold / bucket.successfulOrders;
    final failureRate = bucket.totalOrders == 0 ? 0.0 : bucket.failedOrders * 100 / bucket.totalOrders;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(animation);
        return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
      },
      child: Container(
        key: ValueKey('${bucket.start.toIso8601String()}_${bucket.totalOrders}_${bucket.revenue}_${bucket.foodsSold}'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.65)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(bucket.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(color: scheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('جزئیات بازه', style: theme.textTheme.labelSmall?.copyWith(color: scheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 760 ? 5 : 2;
                final spacing = 8.0;
                final tileWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(width: tileWidth, child: _StatTile(label: 'کل سفارش‌ها', value: _fa(bucket.totalOrders), icon: Icons.receipt_long_outlined, accent: scheme.primary)),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'غذای فروخته‌شده', value: _fa(bucket.foodsSold), icon: Icons.restaurant_outlined, accent: const Color(0xFF0F9D76))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'ارسال / تحویل', value: _fa(bucket.deliveredOrders), icon: Icons.local_shipping_outlined, accent: const Color(0xFF2876D2))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'ناموفق / لغوشده', value: _fa(bucket.failedOrders), icon: Icons.cancel_outlined, accent: scheme.error)),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'درآمد', value: _money(bucket.revenue), icon: Icons.payments_outlined, accent: const Color(0xFFB78016), compact: true)),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'در انتظار', value: _fa(bucket.pendingOrders), icon: Icons.hourglass_bottom_rounded, accent: const Color(0xFF8A55C5))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'سفارش موفق', value: _fa(bucket.successfulOrders), icon: Icons.check_circle_outline_rounded, accent: const Color(0xFF168A67))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'ارسالی با پیک', value: _fa(bucket.deliveryOrders), icon: Icons.local_shipping_outlined, accent: const Color(0xFF2876D2))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'حضوری / بیرون‌بر', value: _fa(bucket.pickupOrders), icon: Icons.storefront_outlined, accent: const Color(0xFF8A55C5))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'میانگین مبلغ سفارش', value: _money(averageOrderAmount), icon: Icons.account_balance_wallet_outlined, accent: const Color(0xFFB78016), compact: true)),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'میانگین غذا در سفارش', value: _fa(averageFoodsPerOrder.toStringAsFixed(1)), icon: Icons.analytics_outlined, accent: const Color(0xFF0F9D76))),
                    SizedBox(width: tileWidth, child: _StatTile(label: 'نرخ سفارش ناموفق', value: '${_fa(failureRate.toStringAsFixed(1))}٪', icon: Icons.trending_down_rounded, accent: scheme.error)),
                  ],
                );
              },
            ),
            if (!supportsFoodBreakdown) ...[
              const SizedBox(height: 10),
              Text(
                'برای محاسبه تعداد غذاهای فروخته‌شده، جدول اقلام سفارش را در تنظیمات Provider معرفی کن.',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text('نمایش روی نمودار', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        Wrap(
          spacing: 7,
          children: [
            _metricChip(context, AnalyticsMetric.orders, 'تعداد سفارش'),
            _metricChip(context, AnalyticsMetric.foods, 'تعداد غذا'),
            _metricChip(context, AnalyticsMetric.revenue, 'درآمد'),
          ],
        ),
      ],
    );
  }

  Widget _metricChip(BuildContext context, AnalyticsMetric metric, String label) {
    final selected = _metric == metric;
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _metric = metric),
      selectedColor: scheme.secondaryContainer,
      backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.35),
      side: BorderSide(color: selected ? scheme.secondary : scheme.outlineVariant.withOpacity(0.6)),
      labelStyle: TextStyle(
        color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      padding: const EdgeInsets.symmetric(horizontal: 5),
    );
  }

  Widget _buildFoodBreakdown(BuildContext context, SalesBucket bucket, bool supportsFoodBreakdown) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 7),
              Expanded(child: Text('غذاهای پرفروش این بازه', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 10),
          if (!supportsFoodBreakdown)
            Text('جدول اقلام سفارش در تنظیمات تعریف نشده است.', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
          else if (bucket.topFoods.isEmpty)
            Text('برای این بازه، قلم فروخته‌شده‌ای ثبت نشده است.', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
          else
            ...bucket.topFoods.asMap().entries.map((entry) {
              final index = entry.key;
              final food = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index == bucket.topFoods.length - 1 ? 0 : 9),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: scheme.primary.withOpacity(0.09), borderRadius: BorderRadius.circular(8)),
                      child: Text(_fa('${index + 1}'), style: theme.textTheme.labelSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 9),
                    Expanded(child: Text(food.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)),
                    const SizedBox(width: 8),
                    Text('${_fa(food.quantity)} عدد', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 10),
                    Text(_money(food.amount), style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 83),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 9),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              value,
              key: ValueKey(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (compact ? theme.textTheme.titleSmall : theme.textTheme.titleLarge)?.copyWith(
                fontWeight: FontWeight.w800,
                color: accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSalesChart extends StatelessWidget {
  const _AnimatedSalesChart({
    required this.height,
    required this.buckets,
    required this.metric,
    required this.selectedIndex,
    required this.color,
    required this.textColor,
    required this.gridColor,
    required this.animationKey,
    required this.onSelect,
  });

  final double height;
  final List<SalesBucket> buckets;
  final AnalyticsMetric metric;
  final int selectedIndex;
  final Color color;
  final Color textColor;
  final Color gridColor;
  final String animationKey;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 600.0;
        return SizedBox(
          width: width,
          height: height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final index = _indexAtPosition(details.localPosition.dx, width, buckets.length);
              if (index != null) onSelect(index);
            },
            child: TweenAnimationBuilder<double>(
              key: ValueKey(animationKey),
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 780),
              curve: Curves.easeOutCubic,
              builder: (context, progress, _) {
                return CustomPaint(
                  size: Size(width, height),
                  painter: _SalesChartPainter(
                    buckets: buckets,
                    metric: metric,
                    selectedIndex: selectedIndex,
                    progress: progress,
                    color: color,
                    textColor: textColor,
                    gridColor: gridColor,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  int? _indexAtPosition(double x, double width, int count) {
    if (count == 0) return null;
    final left = width < 260 ? 38.0 : 46.0;
    const right = 12.0;
    final plotWidth = width - left - right;
    if (x < left || x > width - right || plotWidth <= 0) return null;
    // محور زمان راست‌به‌چپ است: اولین ساعت/روز/ماه در سمت راست قرار می‌گیرد.
    final positionFromLeft = ((x - left) / (plotWidth / count)).floor();
    final index = count - 1 - positionFromLeft;
    return index.clamp(0, count - 1).toInt();
  }
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter({
    required this.buckets,
    required this.metric,
    required this.selectedIndex,
    required this.progress,
    required this.color,
    required this.textColor,
    required this.gridColor,
  });

  final List<SalesBucket> buckets;
  final AnalyticsMetric metric;
  final int selectedIndex;
  final double progress;
  final Color color;
  final Color textColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (buckets.isEmpty || size.width <= 0 || size.height <= 0) return;

    final left = size.width < 260 ? 38.0 : 46.0;
    const right = 12.0;
    const top = 18.0;
    const bottomPadding = 34.0;
    final bottom = size.height - bottomPadding;
    final plotWidth = size.width - left - right;
    final plotHeight = bottom - top;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    final values = buckets.map((bucket) => bucket.valueFor(metric)).toList();
    final actualMax = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final maxValue = actualMax <= 0 ? 5.0 : actualMax * 1.18;

    // خطوط راهنمای افقی و برچسب محور عمودی
    for (var i = 0; i <= 3; i++) {
      final fraction = i / 3;
      final y = bottom - plotHeight * fraction;
      final linePaint = Paint()
        ..color = gridColor.withOpacity(i == 0 ? 0.8 : 0.48)
        ..strokeWidth = i == 0 ? 1.1 : 0.7;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), linePaint);
      _drawText(
        canvas,
        _axisValue(maxValue * fraction, metric),
        Offset(left - 7, y),
        color: textColor.withOpacity(0.85),
        fontSize: 9.5,
        align: TextAlign.end,
      );
    }

    final slotWidth = plotWidth / buckets.length;
    final barWidth = math.max(2.5, math.min(25.0, slotWidth * 0.58)).toDouble();
    final points = <Offset>[];

    for (var index = 0; index < buckets.length; index++) {
      // چون رابط فارسی است، اولین بازه از سمت راست نمودار شروع می‌شود.
      final centerX = size.width - right - slotWidth * (index + 0.5);
      final rawHeight = (values[index] / maxValue) * plotHeight;
      final barHeight = rawHeight * progress;
      final y = bottom - barHeight;
      points.add(Offset(centerX, y));

      if (barHeight > 0.5) {
        final rect = Rect.fromLTWH(centerX - barWidth / 2, y, barWidth, barHeight);
        final selected = index == selectedIndex;
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: selected
              ? [color, color.withOpacity(0.10)]
              : [color.withOpacity(0.78), color.withOpacity(0.035)],
        );
        final barPaint = Paint()..shader = gradient.createShader(rect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(math.min(8.0, barWidth / 2).toDouble())),
          barPaint,
        );
      }

      // در نمودار ۲۴ ساعته برای جلوگیری از فشردگی، برچسب هر سه ساعت نمایش داده می‌شود.
      final labelForPeriod = buckets[index].label;
      final daily = buckets.length == 24;
      if (!daily || index % 3 == 0) {
        _drawText(
          canvas,
          labelForPeriod,
          Offset(centerX, bottom + 17),
          color: index == selectedIndex ? color : textColor.withOpacity(0.8),
          fontSize: daily ? 9.5 : (buckets.length == 12 ? 9 : 10),
          bold: index == selectedIndex,
        );
      }
    }

    // خط رویی، نقاط و ستون‌ها را به هم وصل می‌کند.
    if (points.length > 1) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.95), color.withOpacity(0.72)],
        ).createShader(Rect.fromLTWH(left, top, plotWidth, plotHeight))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linePath, linePaint);
    }

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      if (index == selectedIndex) {
        // خط انتخاب‌شده تا محور پایین، انتخاب ستون را واضح می‌کند.
        final guidePaint = Paint()
          ..color = color.withOpacity(0.35)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        _drawDashedLine(canvas, Offset(point.dx, point.dy + 5), Offset(point.dx, bottom), guidePaint);
        canvas.drawCircle(point, 5.0, Paint()..color = color.withOpacity(0.18));
        canvas.drawCircle(point, 3.4, Paint()..color = color);
        canvas.drawCircle(point, 1.5, Paint()..color = Colors.white);
        _drawText(
          canvas,
          _chartValue(values[index], metric),
          Offset(point.dx, math.max(top + 4, point.dy - 15).toDouble()),
          color: color,
          fontSize: 10.5,
          bold: true,
        );
      } else {
        canvas.drawCircle(point, 2.0, Paint()..color = color.withOpacity(0.8));
      }
    }
  }

  static void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 4.0;
    const gapLength = 4.0;
    final length = (end - start).distance;
    if (length <= 0) return;
    final direction = (end - start) / length;
    var distance = 0.0;
    while (distance < length) {
      final currentEnd = math.min(distance + dashLength, length).toDouble();
      canvas.drawLine(start + direction * distance, start + direction * currentEnd, paint);
      distance += dashLength + gapLength;
    }
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    required Color color,
    required double fontSize,
    TextAlign align = TextAlign.center,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          height: 1.1,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: align,
      maxLines: 1,
    )..layout(maxWidth: 80);

    final x = align == TextAlign.end ? center.dx - painter.width : center.dx - painter.width / 2;
    painter.paint(canvas, Offset(x, center.dy - painter.height / 2));
  }

  static String _axisValue(double value, AnalyticsMetric metric) {
    if (metric != AnalyticsMetric.revenue) return _fa(value.round().toString());
    if (value >= 1000000) return '${_fa((value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1))}م';
    if (value >= 1000) return '${_fa((value / 1000).toStringAsFixed(value >= 10000 ? 0 : 1))}هزار';
    return _fa(value.round().toString());
  }

  static String _chartValue(double value, AnalyticsMetric metric) {
    if (metric == AnalyticsMetric.revenue) return _axisValue(value, metric);
    return _fa(value.round().toString());
  }

  static String _money(double value) => '${_fa(_groupDigits(value.round()))} تومان';

  static String _groupDigits(int value) {
    final source = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < source.length; i++) {
      if (i > 0 && (source.length - i) % 3 == 0) buffer.write('٬');
      buffer.write(source[i]);
    }
    return buffer.toString();
  }

  static String _fa(String value) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    var result = value;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.metric != metric ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.textColor != textColor ||
        oldDelegate.gridColor != gridColor;
  }
}

String _fa(String value) {
  const english = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var result = value;
  for (var i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], persian[i]);
  }
  return result;
}

String _money(double value) {
  final source = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    if (i > 0 && (source.length - i) % 3 == 0) buffer.write('٬');
    buffer.write(source[i]);
  }
  return '${_fa(buffer.toString())} تومان';
}

String _metricLegend(AnalyticsMetric metric) {
  switch (metric) {
    case AnalyticsMetric.orders:
      return 'تعداد سفارش‌ها';
    case AnalyticsMetric.foods:
      return 'تعداد غذاهای فروخته‌شده';
    case AnalyticsMetric.revenue:
      return 'درآمد به تومان';
  }
}