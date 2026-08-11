import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  // پرچم تست: برای اتصال واقعی این را false کنید
  static const bool isMockMode = true; 
  
  AuthProvider(this._authRepository) {
    _init(); 
  }
  
  UserModel? _currentUser; 
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  void _init() {
    if (isMockMode) return; // در حالت تست، چیزی را لود نکن
    
    try {
      _currentUser = _authRepository.getCurrentUser();
      if (_currentUser != null) {
        LoggerService.info('Session restored for user: ${_currentUser!.email}');
      }
    } catch (e) {
      LoggerService.error('Auth init failed', error: e);
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // --- بخش شبیه‌سازی (Mock) ---
    if (isMockMode) {
      await Future.delayed(const Duration(seconds: 1)); // تاخیر ۱ ثانیه‌ای برای نمایش لودینگ
      _currentUser = UserModel(
        id: 'mock-admin-id',
        email: email,
        firstName: 'Admin',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return;
    }
    // -----------------------------

    try {
      final user = await _authRepository.login(email, password);
      _currentUser = user;
      await StorageService.setString('user_id', user.id);
      LoggerService.info('User logged in successfully');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      LoggerService.error('Login failed', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // --- بخش شبیه‌سازی (Mock) ---
    if (isMockMode) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    // -----------------------------

    try {
      await _authRepository.logout();
      _currentUser = null;
      await StorageService.remove('user_id');
      LoggerService.info('User logged out successfully');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      LoggerService.error('Logout failed', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}