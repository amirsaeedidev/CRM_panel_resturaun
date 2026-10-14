import 'package:flutter/foundation.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/restaurant_analytics_models.dart';

/// نام جدول‌ها و ستون‌های Supabase را با ساختار دیتابیس پروژه هماهنگ کن.
/// اگر نام یک ستون اختیاری در دیتابیس وجود ندارد، مقدار آن را null قرار بده.
class RestaurantAnalyticsSchema {
  const RestaurantAnalyticsSchema({
    this.ordersTable = 'orders',
    this.orderIdColumn = 'id',
    this.createdAtColumn = 'created_at',
    this.statusColumn = 'status',
    this.totalAmountColumn = 'total_amount',
    this.orderTypeColumn = 'order_type',
    this.orderItemsTable = 'order_items',
    this.itemOrderIdColumn = 'order_id',
    this.itemRowIdColumn = 'id',
    this.itemQuantityColumn = 'quantity',
    this.itemProductIdColumn = 'product_id',
    this.itemProductNameColumn = 'product_name',
    this.itemUnitPriceColumn = 'price',
  });

  final String ordersTable;
  final String orderIdColumn;
  final String createdAtColumn;
  final String statusColumn;
  final String? totalAmountColumn;
  final String? orderTypeColumn;

  /// برای نمایش تعداد غذاها و پرفروش‌ترین غذاها به جدول اقلام سفارش نیاز است.
  /// اگر نام جدول متفاوت است آن را عوض کن؛ اگر جدول نداری، null قرار بده.
  final String? orderItemsTable;
  final String itemOrderIdColumn;
  final String? itemRowIdColumn;
  final String itemQuantityColumn;
  final String? itemProductIdColumn;
  final String? itemProductNameColumn;
  final String? itemUnitPriceColumn;

  String get orderSelect => _uniqueColumns([
        orderIdColumn,
        createdAtColumn,
        statusColumn,
        totalAmountColumn,
        orderTypeColumn,
      ]).join(',');

  String get itemSelect => _uniqueColumns([
        itemOrderIdColumn,
        itemQuantityColumn,
        itemProductIdColumn,
        itemProductNameColumn,
        itemUnitPriceColumn,
      ]).join(',');

  static List<String> _uniqueColumns(List<String?> columns) {
    return columns.whereType<String>().where((value) => value.trim().isNotEmpty).toSet().toList();
  }
}

/// داده‌های نمودار را یک‌جا از Supabase می‌گیرد و برای UI به بازه‌های زمانی تبدیل می‌کند.
/// برای Provider، انتخاب ستون و تغییر بازه‌ها نیازی به اجرای query در ویجت ندارد.
class RestaurantAnalyticsProvider extends ChangeNotifier {
  RestaurantAnalyticsProvider({
    required SupabaseClient supabase,
    RestaurantAnalyticsSchema schema = const RestaurantAnalyticsSchema(),
  })  : _supabase = supabase,
        _schema = schema {
    _buckets = _makeEmptyBuckets();
    _selectedBucketIndex = _defaultSelectedIndex(_buckets);
  }

  final SupabaseClient _supabase;
  final RestaurantAnalyticsSchema _schema;

  AnalyticsPeriod _period = AnalyticsPeriod.daily;
  DateTime _anchorDate = DateTime.now();
  List<SalesBucket> _buckets = <SalesBucket>[];
  int _selectedBucketIndex = 0;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  int _requestVersion = 0;

  AnalyticsPeriod get period => _period;
  DateTime get anchorDate => _anchorDate;
  List<SalesBucket> get buckets => List.unmodifiable(_buckets);
  int get selectedBucketIndex => _selectedBucketIndex;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  bool get supportsFoodBreakdown => _schema.orderItemsTable != null;

  SalesBucket? get selectedBucket {
    if (_buckets.isEmpty) return null;
    final index = _selectedBucketIndex.clamp(0, _buckets.length - 1).toInt();
    return _buckets[index];
  }

  /// عنوان بازه به تقویم شمسی نمایش داده می‌شود؛ فیلتر دیتابیس بر اساس DateTime است.
  String get rangeLabel {
    switch (_period) {
      case AnalyticsPeriod.daily:
        return 'روز ${_jalaliDate(_anchorDate)}';
      case AnalyticsPeriod.weekly:
        final start = _weekStart(_anchorDate);
        final lastDay = start.add(const Duration(days: 6));
        return '${_jalaliDate(start)} تا ${_jalaliDate(lastDay)}';
      case AnalyticsPeriod.yearly:
        final year = Jalali.fromDateTime(_anchorDate).year;
        return 'سال ${_fa(year.toString())}';
    }
  }

  bool get canGoNext {
    final now = DateTime.now();
    switch (_period) {
      case AnalyticsPeriod.daily:
        return _dayStart(_anchorDate).isBefore(_dayStart(now));
      case AnalyticsPeriod.weekly:
        return _weekStart(_anchorDate).isBefore(_weekStart(now));
      case AnalyticsPeriod.yearly:
        return Jalali.fromDateTime(_anchorDate).year < Jalali.now().year;
    }
  }

  /// بارگذاری یا تازه‌سازی گزارش‌ها.
  Future<void> load() async {
    final requestVersion = ++_requestVersion;
    final hadLoadedData = _hasLoaded;
    final previousIndex = _selectedBucketIndex;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final templates = _makeBucketTemplates();
      final start = templates.first.start;
      final end = templates.last.end;

      // بازه به UTC تبدیل می‌شود تا با ستون timestamptz در PostgreSQL درست فیلتر شود.
      final orders = await _fetchOrders(start, end);
      if (requestVersion != _requestVersion) return;

      final orderMeta = <String, _OrderMeta>{};
      final orderIdsForItems = <dynamic>[];
      final accumulators = templates.map(_BucketAccumulator.fromTemplate).toList();

      for (final row in orders) {
        final rawId = row[_schema.orderIdColumn];
        final rawDate = row[_schema.createdAtColumn];
        if (rawId == null || rawDate == null) continue;

        final createdAt = DateTime.tryParse(rawDate.toString());
        if (createdAt == null) continue;

        final bucketIndex = _findBucketIndex(templates, createdAt);
        if (bucketIndex < 0) continue;

        final orderId = rawId.toString();
        final status = (row[_schema.statusColumn] ?? '').toString().trim().toLowerCase();
        final failed = _isFailedStatus(status);
        final pending = _isPendingStatus(status);
        final delivered = _isDeliveredStatus(status);
        final total = _asDouble(
          _schema.totalAmountColumn == null ? null : row[_schema.totalAmountColumn],
        );
        final orderType = (_schema.orderTypeColumn == null ? '' : row[_schema.orderTypeColumn] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        final bucket = accumulators[bucketIndex];
        bucket.totalOrders++;
        if (failed) {
          bucket.failedOrders++;
        } else {
          // درآمد سفارش‌های لغوشده/ناموفق وارد جمع فروش نمی‌شود.
          bucket.revenue += total;
          if (pending) {
            bucket.pendingOrders++;
          } else {
            bucket.successfulOrders++;
          }
          if (delivered) bucket.deliveredOrders++;
        }

        if (_isDeliveryOrder(orderType)) bucket.deliveryOrders++;
        if (_isPickupOrder(orderType)) bucket.pickupOrders++;

        orderMeta[orderId] = _OrderMeta(bucketIndex: bucketIndex, failed: failed);
        // اقلام سفارش‌های ناموفق برای گزارش غذای فروخته‌شده خوانده نمی‌شوند.
        if (!failed) orderIdsForItems.add(rawId);
      }

      if (_schema.orderItemsTable != null && orderIdsForItems.isNotEmpty) {
        final uniqueIds = orderIdsForItems.toSet().toList();
        final items = await _fetchItems(uniqueIds);
        if (requestVersion != _requestVersion) return;

        for (final item in items) {
          final orderId = item[_schema.itemOrderIdColumn]?.toString();
          if (orderId == null) continue;
          final meta = orderMeta[orderId];
          if (meta == null || meta.failed) continue;

          final quantity = _asInt(item[_schema.itemQuantityColumn]);
          if (quantity <= 0) continue;

          final rawName = _schema.itemProductNameColumn == null
              ? null
              : item[_schema.itemProductNameColumn];
          final rawProductId = _schema.itemProductIdColumn == null
              ? null
              : item[_schema.itemProductIdColumn];
          final foodName = (rawName ?? rawProductId ?? 'غذای بدون نام').toString().trim();
          final unitPrice = _asDouble(
            _schema.itemUnitPriceColumn == null ? null : item[_schema.itemUnitPriceColumn],
          );

          final bucket = accumulators[meta.bucketIndex];
          bucket.foodsSold += quantity;
          final food = bucket.foods.putIfAbsent(foodName, () => _FoodAccumulator(foodName));
          food.quantity += quantity;
          food.amount += unitPrice * quantity;
        }
      }

      if (requestVersion != _requestVersion) return;
      _buckets = accumulators.map((bucket) => bucket.toModel()).toList(growable: false);
      _selectedBucketIndex = hadLoadedData
          ? previousIndex.clamp(0, _buckets.length - 1).toInt()
          : _defaultSelectedIndex(_buckets);
      _hasLoaded = true;
    } catch (error, stackTrace) {
      debugPrint('Restaurant analytics load failed: $error\n$stackTrace');
      if (requestVersion == _requestVersion) {
        _errorMessage = 'گزارش دریافت نشد. نام جدول‌ها، ستون‌ها و دسترسی خواندن در Supabase را بررسی کن.';
        _hasLoaded = true;
      }
    } finally {
      if (requestVersion == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() => load();

  Future<void> setPeriod(AnalyticsPeriod period) async {
    if (_period == period) return;
    _period = period;
    // با عوض‌شدن نوع نمودار، آخرین بازهٔ جاری نمایش داده می‌شود.
    _anchorDate = DateTime.now();
    _hasLoaded = false;
    _buckets = _makeEmptyBuckets();
    _selectedBucketIndex = _defaultSelectedIndex(_buckets);
    notifyListeners();
    await load();
  }

  void selectBucket(int index) {
    if (index < 0 || index >= _buckets.length || index == _selectedBucketIndex) return;
    _selectedBucketIndex = index;
    notifyListeners();
  }

  Future<void> goToPreviousRange() async {
    switch (_period) {
      case AnalyticsPeriod.daily:
        _anchorDate = _dayStart(_anchorDate).subtract(const Duration(days: 1));
        break;
      case AnalyticsPeriod.weekly:
        _anchorDate = _weekStart(_anchorDate).subtract(const Duration(days: 7));
        break;
      case AnalyticsPeriod.yearly:
        final year = Jalali.fromDateTime(_anchorDate).year;
        _anchorDate = Jalali(year - 1, 1, 1).toDateTime();
        break;
    }
    _hasLoaded = false;
    _buckets = _makeEmptyBuckets();
    _selectedBucketIndex = _defaultSelectedIndex(_buckets);
    notifyListeners();
    await load();
  }

  Future<void> goToNextRange() async {
    if (!canGoNext) return;
    switch (_period) {
      case AnalyticsPeriod.daily:
        _anchorDate = _dayStart(_anchorDate).add(const Duration(days: 1));
        break;
      case AnalyticsPeriod.weekly:
        _anchorDate = _weekStart(_anchorDate).add(const Duration(days: 7));
        break;
      case AnalyticsPeriod.yearly:
        final year = Jalali.fromDateTime(_anchorDate).year;
        _anchorDate = Jalali(year + 1, 1, 1).toDateTime();
        break;
    }
    _hasLoaded = false;
    _buckets = _makeEmptyBuckets();
    _selectedBucketIndex = _defaultSelectedIndex(_buckets);
    notifyListeners();
    await load();
  }

  /// با صفحه‌بندی از ناقص شدن نتیجه به‌خاطر سقف ردیف‌های PostgREST جلوگیری می‌شود.
  Future<List<Map<String, dynamic>>> _fetchOrders(DateTime start, DateTime end) async {
    const pageSize = 500;
    final result = <Map<String, dynamic>>[];
    var offset = 0;

    while (true) {
      final page = await _supabase
          .from(_schema.ordersTable)
          .select(_schema.orderSelect)
          .gte(_schema.createdAtColumn, start.toUtc().toIso8601String())
          .lt(_schema.createdAtColumn, end.toUtc().toIso8601String())
          .order(_schema.createdAtColumn)
          .range(offset, offset + pageSize - 1);

      final rows = List<Map<String, dynamic>>.from(page);
      result.addAll(rows);
      if (rows.length < pageSize) break;
      offset += pageSize;
    }
    return result;
  }

  /// اقلام را در دسته‌های شناسه‌ای می‌خوانیم تا URL فیلتر بیش از حد بزرگ نشود.
  Future<List<Map<String, dynamic>>> _fetchItems(List<dynamic> orderIds) async {
    final table = _schema.orderItemsTable;
    if (table == null || orderIds.isEmpty) return <Map<String, dynamic>>[];

    const idBatchSize = 150;
    const pageSize = 500;
    final result = <Map<String, dynamic>>[];

    for (var batchStart = 0; batchStart < orderIds.length; batchStart += idBatchSize) {
      final batch = orderIds.skip(batchStart).take(idBatchSize).toList();
      var offset = 0;

      while (true) {
        final page = await _supabase
            .from(table)
            .select(_schema.itemSelect)
            .inFilter(_schema.itemOrderIdColumn, batch)
            // مرتب‌سازی با شناسهٔ قلم باعث می‌شود صفحه‌بندی اقلام پایدار بماند.
            .order(_schema.itemRowIdColumn ?? _schema.itemOrderIdColumn)
            .range(offset, offset + pageSize - 1);

        final rows = List<Map<String, dynamic>>.from(page);
        result.addAll(rows);
        if (rows.length < pageSize) break;
        offset += pageSize;
      }
    }
    return result;
  }

  List<_BucketTemplate> _makeBucketTemplates() {
    switch (_period) {
      case AnalyticsPeriod.daily:
        final dayStart = _dayStart(_anchorDate);
        return List.generate(24, (hour) {
          final start = dayStart.add(Duration(hours: hour));
          final end = start.add(const Duration(hours: 1));
          final nextHour = (hour + 1) % 24;
          final startText = '${_fa(hour.toString().padLeft(2, '0'))}:۰۰';
          final endText = '${_fa(nextHour.toString().padLeft(2, '0'))}:۰۰';
          return _BucketTemplate(
            start: start,
            end: end,
            label: _fa(hour.toString().padLeft(2, '0')),
            title: 'ساعت $startText تا $endText',
          );
        });
      case AnalyticsPeriod.weekly:
        final weekStart = _weekStart(_anchorDate);
        return List.generate(7, (index) {
          final start = weekStart.add(Duration(days: index));
          final end = start.add(const Duration(days: 1));
          final dayName = _weekdayName(start.weekday);
          return _BucketTemplate(
            start: start,
            end: end,
            label: _weekdayShort(start.weekday),
            title: '$dayName ${_jalaliDate(start)}',
          );
        });
      case AnalyticsPeriod.yearly:
        final jalaliYear = Jalali.fromDateTime(_anchorDate).year;
        return List.generate(12, (index) {
          final month = index + 1;
          final start = Jalali(jalaliYear, month, 1).toDateTime();
          final end = month == 12
              ? Jalali(jalaliYear + 1, 1, 1).toDateTime()
              : Jalali(jalaliYear, month + 1, 1).toDateTime();
          return _BucketTemplate(
            start: start,
            end: end,
            label: _monthShort(month),
            title: '${_monthName(month)} ${_fa(jalaliYear.toString())}',
          );
        });
    }
  }

  List<SalesBucket> _makeEmptyBuckets() =>
      _makeBucketTemplates().map((template) => _BucketAccumulator.fromTemplate(template).toModel()).toList();

  int _defaultSelectedIndex(List<SalesBucket> buckets) {
    if (buckets.isEmpty) return 0;
    switch (_period) {
      case AnalyticsPeriod.daily:
        return DateTime.now().hour.clamp(0, buckets.length - 1).toInt();
      case AnalyticsPeriod.weekly:
        final index = (DateTime.now().weekday + 1) % 7; // هفته از شنبه شروع می‌شود.
        return index.clamp(0, buckets.length - 1).toInt();
      case AnalyticsPeriod.yearly:
        final month = Jalali.now().month - 1;
        return month.clamp(0, buckets.length - 1).toInt();
    }
  }

  int _findBucketIndex(List<_BucketTemplate> buckets, DateTime date) {
    for (var i = 0; i < buckets.length; i++) {
      if (!date.isBefore(buckets[i].start) && date.isBefore(buckets[i].end)) return i;
    }
    return -1;
  }

  DateTime _dayStart(DateTime value) => DateTime(value.year, value.month, value.day);

  DateTime _weekStart(DateTime value) {
    // DateTime: دوشنبه=۱ ... یکشنبه=۷؛ فرمول زیر شنبه را ابتدای هفته می‌کند.
    final daysSinceSaturday = (value.weekday + 1) % 7;
    return _dayStart(value).subtract(Duration(days: daysSinceSaturday));
  }

  bool _isFailedStatus(String status) {
    const exact = {
      'cancelled', 'canceled', 'failed', 'rejected', 'unsuccessful', 'ناموفق', 'لغو شده', 'لغو', 'رد شده',
    };
    return exact.contains(status) || status.contains('ناموفق') || status.contains('لغو') || status.contains('رد شده');
  }

  bool _isPendingStatus(String status) {
    const exact = {'pending', 'new', 'processing', 'preparing', 'waiting_payment', 'در انتظار', 'در حال آماده سازی'};
    return exact.contains(status) || status.contains('در انتظار') || status.contains('آماده سازی') || status.contains('در حال بررسی');
  }

  bool _isDeliveredStatus(String status) {
    const exact = {'delivered', 'shipped', 'sent', 'served', 'تحویل شده', 'ارسال شده', 'تحویل داده شده'};
    return exact.contains(status) || status.contains('تحویل شده') || status.contains('ارسال شده');
  }

  bool _isDeliveryOrder(String orderType) =>
      orderType.contains('delivery') || orderType.contains('ارسال') || orderType.contains('پیک');

  bool _isPickupOrder(String orderType) =>
      orderType.contains('pickup') || orderType.contains('takeaway') || orderType.contains('حضوری') || orderType.contains('بیرون‌بر');

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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

  static String _jalaliDate(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${_fa(j.day.toString())} ${_monthName(j.month)} ${_fa(j.year.toString())}';
  }

  static String _weekdayName(int weekday) {
    const names = ['دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه', 'شنبه', 'یکشنبه'];
    return names[(weekday - 1).clamp(0, 6).toInt()];
  }

  static String _weekdayShort(int weekday) {
    const names = ['دو', 'سه', 'چه', 'پن', 'جم', 'شن', 'یک'];
    return names[(weekday - 1).clamp(0, 6).toInt()];
  }

  static String _monthName(int month) {
    const names = [
      'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
      'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
    ];
    return names[(month - 1).clamp(0, 11).toInt()];
  }

  static String _monthShort(int month) {
    const names = ['فرو', 'ارد', 'خرد', 'تیر', 'مرد', 'شهر', 'مهر', 'آبا', 'آذر', 'دی', 'بهم', 'اسف'];
    return names[(month - 1).clamp(0, 11).toInt()];
  }
}

class _BucketTemplate {
  const _BucketTemplate({required this.start, required this.end, required this.label, required this.title});
  final DateTime start;
  final DateTime end;
  final String label;
  final String title;
}

class _OrderMeta {
  const _OrderMeta({required this.bucketIndex, required this.failed});
  final int bucketIndex;
  final bool failed;
}

class _FoodAccumulator {
  _FoodAccumulator(this.name);
  final String name;
  int quantity = 0;
  double amount = 0;
}

class _BucketAccumulator {
  _BucketAccumulator({required this.template});

  factory _BucketAccumulator.fromTemplate(_BucketTemplate template) => _BucketAccumulator(template: template);

  final _BucketTemplate template;
  int totalOrders = 0;
  int successfulOrders = 0;
  int deliveredOrders = 0;
  int failedOrders = 0;
  int pendingOrders = 0;
  int foodsSold = 0;
  double revenue = 0;
  int deliveryOrders = 0;
  int pickupOrders = 0;
  final Map<String, _FoodAccumulator> foods = <String, _FoodAccumulator>{};

  SalesBucket toModel() {
    final sortedFoods = foods.values.toList()..sort((a, b) => b.quantity.compareTo(a.quantity));
    return SalesBucket(
      start: template.start,
      end: template.end,
      label: template.label,
      title: template.title,
      totalOrders: totalOrders,
      successfulOrders: successfulOrders,
      deliveredOrders: deliveredOrders,
      failedOrders: failedOrders,
      pendingOrders: pendingOrders,
      foodsSold: foodsSold,
      revenue: revenue,
      deliveryOrders: deliveryOrders,
      pickupOrders: pickupOrders,
      topFoods: sortedFoods
          .take(5)
          .map((food) => FoodSales(name: food.name, quantity: food.quantity, amount: food.amount))
          .toList(growable: false),
    );
  }
}