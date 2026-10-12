import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../models/statistics_model.dart';
import '../models/order_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
final DashboardRepository _repository;
DashboardProvider(this._repository);

bool _isLoading = false;
String? _error;
StatisticsModel? _statistics;
List<OrderModel> _recentOrders = [];

bool get isLoading => _isLoading;
String? get error => _error;
StatisticsModel? get statistics => _statistics;
List<OrderModel> get recentOrders => _recentOrders;

Future<void> fetchDashboardData() async {
_isLoading = true;
_error = null;
notifyListeners();

try {
// دریافت آمار و سفارشات اخیر به صورت همزمان برای افزایش سرعت
final results = await Future.wait([
_repository.getStatistics(),
_repository.getRecentOrders(limit: 5),
]);

_statistics = results[0] as StatisticsModel;
_recentOrders = results[1] as List<OrderModel>;

} catch (e, st) {
LoggerService.error('Fetch dashboard data failed', error: e, stackTrace: st);
_error = e.toString();
} finally {
_isLoading = false;
notifyListeners();
}
}
}