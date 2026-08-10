import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../models/category_model.dart';
import '../repositories/categories_repository.dart';

class CategoriesProvider extends ChangeNotifier {
  final CategoriesRepository _repository;
  CategoriesProvider(this._repository);

  // List State
  bool _isLoading = false;
  bool _isSaving = false; // For form submission
  String? _error;
  List<CategoryModel> _categories = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _pageSize = 15;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  List<CategoryModel> get categories => _categories;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      // Basic pagination logic
      _totalPages = _categories.length == _pageSize ? _currentPage + 1 : _currentPage;
      
    } catch (e, st) {
      LoggerService.error('Fetch categories failed in provider', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await fetchCategories();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    await fetchCategories();
  }

  // Helper for Form Screen
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final newCategory = await _repository.createCategory(data);
      _categories.insert(0, newCategory);
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Create category failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCategory = await _repository.updateCategory(id, data);
      
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Update category failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Delete category failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    }
  }
}