import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../models/product_model.dart';
import '../repositories/products_repository.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductsRepository _repository;
  ProductsProvider(this._repository);

  // List State
  bool _isLoading = false;
  bool _isSaving = false; // For form submission
  String? _error;
  List<ProductModel> _products = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _pageSize = 15;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  List<ProductModel> get products => _products;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getProducts(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );
      
      // Basic pagination logic
      _totalPages = _products.length == _pageSize ? _currentPage + 1 : _currentPage;
      
    } catch (e, st) {
      LoggerService.error('Fetch products failed in provider', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await fetchProducts();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    await fetchProducts();
  }

  // Helper for Form Screen
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final newProduct = await _repository.createProduct(data);
      _products.insert(0, newProduct);
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Create product failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> data) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProduct = await _repository.updateProduct(id, data);
      
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Update product failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Delete product failed in provider', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    }
  }

  // Quick toggle status for List Screen
  Future<bool> toggleProductStatus(String id, bool makeAvailable) async {
    try {
      final newStatus = makeAvailable ? 'active' : 'inactive';
      await _repository.updateProduct(id, {'status': newStatus});
      
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = _products[index].copyWith(status: newStatus);
        notifyListeners();
      }
      return true;
    } catch (e, st) {
      LoggerService.error('Toggle product status failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    }
  }
}