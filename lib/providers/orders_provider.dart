import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../repositories/orders_repository.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersRepository _repository;
  OrdersProvider(this._repository);

  // List State
  bool _isLoading = false;
  String? _error;
  List<OrderModel> _orders = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _statusFilter = 'all';
  final int _pageSize = 15;

  // Details State
  OrderModel? _selectedOrder;
  bool _isLoadingDetails = false;
  String? _detailsError;
  bool _isUpdatingStatus = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isUpdatingStatus => _isUpdatingStatus;
  String? get error => _error;
  String? get detailsError => _detailsError;
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.getOrders(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        status: _statusFilter == 'all' ? null : _statusFilter,
      );
      
      // Basic pagination logic: if we fetched exactly the page size, assume there might be more
      _totalPages = _orders.length == _pageSize ? _currentPage + 1 : _currentPage;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails(String id) async {
    _isLoadingDetails = true;
    _detailsError = null;
    _selectedOrder = null;
    notifyListeners();

    try {
      _selectedOrder = await _repository.getOrderById(id);
    } catch (e) {
      _detailsError = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await fetchOrders();
  }

  Future<void> setStatusFilter(String status) async {
    _statusFilter = status;
    _currentPage = 1;
    await fetchOrders();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    await fetchOrders();
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _isUpdatingStatus = true;
    notifyListeners();

    try {
      await _repository.updateOrderStatus(orderId, newStatus);
      
      // Update local state
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
      }
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = _selectedOrder!.copyWith(status: newStatus);
      }
      return true;
    } catch (e) {
      _detailsError = e.toString();
      return false;
    } finally {
      _isUpdatingStatus = false;
      notifyListeners();
    }
  }

  Future<bool> updateEstimatedDeliveryTime(String orderId, int minutes) async {
    try {
      // Assumes repository has a generic update method or specific method for this
      // await _repository.updateOrderMetadata(orderId, {'estimated_delivery_time': minutes});
      
      if (_selectedOrder?.id == orderId) {
        // _selectedOrder = _selectedOrder!.copyWith(estimatedDeliveryTime: minutes);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _detailsError = e.toString();
      return false;
    }
  }
}