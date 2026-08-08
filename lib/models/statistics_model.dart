class StatisticsModel {
  final double totalSales;
  final int totalOrders;
  final int totalCustomers;
  final int totalProducts;
  final double salesGrowthPercentage;
  final double ordersGrowthPercentage;
  final double customersGrowthPercentage;
  final String period; // e.g., 'weekly', 'monthly', 'yearly'
  final DateTime updatedAt;

  StatisticsModel({
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
    return StatisticsModel(
      totalSales: (json['total_sales'] as num).toDouble(),
      totalOrders: json['total_orders'] as int? ?? 0,
      totalCustomers: json['total_customers'] as int? ?? 0,
      totalProducts: json['total_products'] as int? ?? 0,
      salesGrowthPercentage: (json['sales_growth_percentage'] as num?)?.toDouble() ?? 0.0,
      ordersGrowthPercentage: (json['orders_growth_percentage'] as num?)?.toDouble() ?? 0.0,
      customersGrowthPercentage: (json['customers_growth_percentage'] as num?)?.toDouble() ?? 0.0,
      period: json['period'] as String? ?? 'monthly',
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
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
      salesGrowthPercentage: salesGrowthPercentage ?? this.salesGrowthPercentage,
      ordersGrowthPercentage: ordersGrowthPercentage ?? this.ordersGrowthPercentage,
      customersGrowthPercentage: customersGrowthPercentage ?? this.customersGrowthPercentage,
      period: period ?? this.period,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}