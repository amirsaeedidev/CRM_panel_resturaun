import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../models/reservation_model.dart';
import '../repositories/reservations_repository.dart';

class ReservationsProvider extends ChangeNotifier {
  final ReservationsRepository _repository;
  ReservationsProvider(this._repository);

  // List State
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  List<ReservationModel> _reservations = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'pending', 'confirmed', etc.
  final int _pageSize = 15;

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  List<ReservationModel> get reservations => _reservations;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  Future<void> fetchReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _repository.getReservations(
        page: _currentPage,
        pageSize: _pageSize,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        status: _statusFilter == 'all' ? null : _statusFilter,
      );
      
      _totalPages = _reservations.length == _pageSize ? _currentPage + 1 : _currentPage;
      
    } catch (e, st) {
      LoggerService.error('Fetch reservations failed in provider', error: e, stackTrace: st);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await fetchReservations();
  }

  Future<void> setStatusFilter(String status) async {
    _statusFilter = status;
    _currentPage = 1;
    await fetchReservations();
  }

  Future<void> changePage(int page) async {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    await fetchReservations();
  }

  Future<bool> updateReservationStatus(String id, String newStatus) async {
    _isUpdating = true;
    notifyListeners();

    try {
      await _repository.updateReservationStatus(id, newStatus);
      
      final index = _reservations.indexWhere((r) => r.id == id);
      if (index != -1) {
        final updated = _reservations[index].copyWith(
          status: ReservationStatusX.fromString(newStatus),
        );
        _reservations[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e, st) {
      LoggerService.error('Update reservation status failed', error: e, stackTrace: st);
      _error = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}