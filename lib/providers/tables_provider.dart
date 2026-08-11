import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../models/table_model.dart';
import '../repositories/tables_repository.dart';

class TablesProvider extends ChangeNotifier {
  final TablesRepository _repository;
  TablesProvider(this._repository);

  // State
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  List<TableModel> _tables = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  List<TableModel> get tables => _tables;

  Future<void> fetchTables() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tables = await _repository.getTables();
    } catch (e, st) {
      LoggerService.error('Fetch tables failed in provider', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markTableAsFree(String tableId) async {
    _isUpdating = true;
    notifyListeners();

    try {
      await _repository.updateTableStatus(tableId, 'free', null);
      
      final index = _tables.indexWhere((t) => t.id == tableId);
      if (index != -1) {
        _tables[index] = _tables[index].copyWith(
          status: TableStatus.free,
          currentOrderId: null,
        );
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Mark table as free failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> assignOrderToTable(String tableId, String orderId) async {
    _isUpdating = true;
    notifyListeners();

    try {
      await _repository.updateTableStatus(tableId, 'occupied', orderId);
      
      final index = _tables.indexWhere((t) => t.id == tableId);
      if (index != -1) {
        _tables[index] = _tables[index].copyWith(
          status: TableStatus.occupied,
          currentOrderId: orderId,
        );
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Assign order to table failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}