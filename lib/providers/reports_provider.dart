import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../models/report_model.dart';
import '../repositories/reports_repository.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsRepository _repository;
  ReportsProvider(this._repository);

  // State
  bool _isLoading = false;
  String? _error;
  ReportModel? _salesReport;
  List<Map<String, dynamic>> _topProducts = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ReportModel? get salesReport => _salesReport;
  List<Map<String, dynamic>> get topProducts => _topProducts;

  Future<void> fetchSalesReport({required DateTime startDate, required DateTime endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salesReport = await _repository.getSalesReport(startDate: startDate, endDate: endDate);
      // Also fetch top products for the selected period
      await fetchTopProducts(startDate: startDate, endDate: endDate);
    } catch (e, st) {
      LoggerService.error('Fetch sales report failed in provider', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTopProducts({required DateTime startDate, required DateTime endDate, int limit = 10}) async {
    try {
      _topProducts = await _repository.getTopProducts(startDate: startDate, endDate: endDate, limit: limit);
      notifyListeners();
    } catch (e, st) {
      LoggerService.error('Fetch top products failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      notifyListeners();
    }
  }
}