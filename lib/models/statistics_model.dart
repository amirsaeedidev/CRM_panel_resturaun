class StatisticsModel {
  final double totalSales;
  final int totalOrders;
  final int totalCustomers;
  final int totalProducts;
  final double salesGrowthPercentage;
  final double ordersGrowthPercentage;
  final double customersGrowthPercentage;
  final String period;
  final DateTime updatedAt;

  const StatisticsModel({
    required this.totalSales,
    required this.totalOrders,
    required this.totalCustomers,
    required this.totalProducts,
    required this.salesGrowthPercentage,
    required this.ordersGrowthPercentage,
    required this.customersGrowthPercentage,
    required this.period,
    required this.updatedAt,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    final updatedAtValue = json['updated_at'];

    final DateTime? parsedUpdatedAt = updatedAtValue is String
        ? DateTime.tryParse(updatedAtValue)
        : updatedAtValue is DateTime
            ? updatedAtValue
            : null;

    if (parsedUpdatedAt == null) {
      throw const FormatException(
        'فیلد updated_at در پاسخ آمار داشبورد نامعتبر است.',
      );
    }

    return StatisticsModel(
      totalSales: _requiredNumber(json, 'total_sales').toDouble(),
      totalOrders: _requiredNumber(json, 'total_orders').toInt(),
      totalCustomers: _requiredNumber(json, 'total_customers').toInt(),
      totalProducts: _requiredNumber(json, 'total_products').toInt(),
      salesGrowthPercentage:
          _optionalNumber(json, 'sales_growth_percentage').toDouble(),
      ordersGrowthPercentage:
          _optionalNumber(json, 'orders_growth_percentage').toDouble(),
      customersGrowthPercentage:
          _optionalNumber(json, 'customers_growth_percentage').toDouble(),
      period: json['period'] is String
          ? json['period'] as String
          : 'monthly',
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Required numeric values must exist in the server response.
  static num _requiredNumber(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];

    if (value is num) return value;

    if (value is String) {
      final parsed = num.tryParse(value);
      if (parsed != null) return parsed;
    }

    throw FormatException(
      'فیلد "$key" در پاسخ آمار داشبورد وجود ندارد '
      'یا عدد معتبر نیست.',
    );
  }

  /// Optional growth values default to zero when the server omits them.
  static num _optionalNumber(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];

    if (value is num) return value;

    if (value is String) {
      return num.tryParse(value) ?? 0;
    }

    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sales': totalSales,
      'total_orders': totalOrders,
      'total_customers': totalCustomers,
      'total_products': totalProducts,
      'sales_growth_percentage': salesGrowthPercentage,
      'orders_growth_percentage': ordersGrowthPercentage,
      'customers_growth_percentage': customersGrowthPercentage,
      'period': period,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StatisticsModel copyWith({
    double? totalSales,
    int? totalOrders,
    int? totalCustomers,
    int? totalProducts,
    double? salesGrowthPercentage,
    double? ordersGrowthPercentage,
    double? customersGrowthPercentage,
    String? period,
    DateTime? updatedAt,
  }) {
    return StatisticsModel(
      totalSales: totalSales ?? this.totalSales,
      totalOrders: totalOrders ?? this.totalOrders,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalProducts: totalProducts ?? this.totalProducts,
      salesGrowthPercentage:
          salesGrowthPercentage ?? this.salesGrowthPercentage,
      ordersGrowthPercentage:
          ordersGrowthPercentage ?? this.ordersGrowthPercentage,
      customersGrowthPercentage:
          customersGrowthPercentage ?? this.customersGrowthPercentage,
      period: period ?? this.period,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}