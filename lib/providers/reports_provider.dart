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
  ReportModel? _topProductsReport;
  ReportModel? _customerDistributionReport;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  ReportModel? get salesReport => _salesReport;
  ReportModel? get topProductsReport => _topProductsReport;
  ReportModel? get customerDistributionReport => _customerDistributionReport;

  Future<void> fetchSalesReport({required DateTime startDate, required DateTime endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salesReport = await _repository.getSalesReport(startDate: startDate, endDate: endDate);
    } catch (e, st) {
      LoggerService.error('Fetch sales report failed in provider', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTopProductsReport({int limit = 10}) async {
    try {
      _topProductsReport = await _repository.getTopProductsReport(limit: limit);
      notifyListeners();
    } catch (e, st) {
      LoggerService.error('Fetch top products report failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCustomerDistributionReport() async {
    try {
      _customerDistributionReport = await _repository.getCustomerDistributionReport();
      notifyListeners();
    } catch (e, st) {
      LoggerService.error('Fetch customer distribution report failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      notifyListeners();
    }
  }
}