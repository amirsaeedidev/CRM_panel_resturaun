import 'package:flutter/material.dart';

import '../core/services/logger_service.dart';
import '../models/statistics_model.dart';
import '../models/order_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardProvider(this._repository);

  bool _isLoading = false;
  bool _disposed = false;

  String? _error;
  String? _recentOrdersError;

  StatisticsModel? _statistics;
  List<OrderModel> _recentOrders = [];

  bool get isLoading => _isLoading;

  /// Error loading dashboard statistics.
  String? get error => _error;

  /// Error loading recent orders.
  String? get recentOrdersError => _recentOrdersError;

  StatisticsModel? get statistics => _statistics;

  List<OrderModel> get recentOrders => List.unmodifiable(_recentOrders);

  /// Fetch statistics and recent orders concurrently.
  ///
  /// A failure in one request will not prevent the other
  /// request from updating its data.
  Future<void> fetchDashboardData() async {
    if (_disposed || _isLoading) return;

    _isLoading = true;
    _error = null;
    _recentOrdersError = null;

    _notifyIfAlive();

    try {
      await Future.wait<void>([_fetchStatistics(), _fetchRecentOrders()]);
    } catch (e, st) {
      // The individual methods handle their own errors.
      // This catch protects against unexpected failures.
      LoggerService.error(
        'Unexpected dashboard loading failure',
        error: e,
        stackTrace: st,
      );
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notifyIfAlive();
      }
    }
  }

  /// Fetch statistics independently.
  Future<void> _fetchStatistics() async {
    try {
      final result = await _repository.getStatistics();

      if (_disposed) return;

      _statistics = result;
      _error = null;

      LoggerService.info('Dashboard statistics loaded successfully');
    } catch (e, st) {
      if (_disposed) return;

      _error = _readableError(e);

      LoggerService.error(
        'Failed to fetch dashboard statistics',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Fetch recent orders independently.
  Future<void> _fetchRecentOrders() async {
    try {
      final result = await _repository.getRecentOrders(limit: 5);

      if (_disposed) return;

      _recentOrders = result;
      _recentOrdersError = null;

      LoggerService.info('Recent dashboard orders loaded successfully');
    } catch (e, st) {
      if (_disposed) return;

      _recentOrdersError = _readableError(e);

      LoggerService.error(
        'Failed to fetch recent dashboard orders',
        error: e,
        stackTrace: st,
      );
    }
  }

  String _readableError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';

    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }

    return message;
  }

  void _notifyIfAlive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
