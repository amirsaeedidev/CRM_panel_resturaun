import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../models/discount_model.dart';
import '../repositories/discounts_repository.dart';

class DiscountsProvider extends ChangeNotifier {
  final DiscountsRepository _repository;
  DiscountsProvider(this._repository);

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  List<DiscountModel> _discounts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _pageSize = 15;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  List<DiscountModel> get discounts => _discounts;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;

  Future<void> fetchDiscounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _discounts = await _repository.getDiscounts(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
      _totalPages = _discounts.length == _pageSize ? _currentPage + 1 : _currentPage;
    } catch (e, st) {
      LoggerService.error('Fetch discounts failed', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await fetchDiscounts();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    await fetchDiscounts();
  }

  DiscountModel? getDiscountById(String id) {
    try {
      return _discounts.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createDiscount(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final newDiscount = await _repository.createDiscount(data);
      _discounts.insert(0, newDiscount);
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Create discount failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateDiscount(String id, Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDiscount = await _repository.updateDiscount(id, data);
      final index = _discounts.indexWhere((d) => d.id == id);
      if (index != -1) {
        _discounts[index] = updatedDiscount;
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Update discount failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDiscount(String id) async {
    try {
      await _repository.deleteDiscount(id);
      _discounts.removeWhere((d) => d.id == id);
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Delete discount failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    }
  }

  Future<bool> toggleDiscountStatus(String id, bool isActive) async {
    try {
      await _repository.updateDiscount(id, {'is_active': isActive});
      final index = _discounts.indexWhere((d) => d.id == id);
      if (index != -1) {
        _discounts[index] = _discounts[index].copyWith(isActive: isActive);
        notifyListeners();
      }
      return true;
    } catch (e, st) {
      LoggerService.error('Toggle discount status failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    }
  }
}