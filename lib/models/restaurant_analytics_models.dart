// مدل‌های گزارش فروش رستوران

enum AnalyticsPeriod { daily, weekly, yearly }

enum AnalyticsMetric { orders, foods, revenue }

class FoodSales {
  const FoodSales({
    required this.name,
    required this.quantity,
    required this.amount,
  });

  final String name;
  final int quantity;
  final double amount;
}

class SalesBucket {
  const SalesBucket({
    required this.start,
    required this.end,
    required this.label,
    required this.title,
    required this.totalOrders,
    required this.successfulOrders,
    required this.deliveredOrders,
    required this.failedOrders,
    required this.pendingOrders,
    required this.foodsSold,
    required this.revenue,
    required this.deliveryOrders,
    required this.pickupOrders,
    required this.topFoods,
  });

  final DateTime start;
  final DateTime end;
  final String label;
  final String title;
  final int totalOrders;
  final int successfulOrders;
  final int deliveredOrders;
  final int failedOrders;
  final int pendingOrders;
  final int foodsSold;
  final double revenue;
  final int deliveryOrders;
  final int pickupOrders;
  final List<FoodSales> topFoods;

  /// مقداری که نمودار بر اساس شاخص انتخاب‌شده نمایش می‌دهد.
  double valueFor(AnalyticsMetric metric) {
    switch (metric) {
      case AnalyticsMetric.orders:
        return totalOrders.toDouble();
      case AnalyticsMetric.foods:
        return foodsSold.toDouble();
      case AnalyticsMetric.revenue:
        return revenue;
    }
  }
}