import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for User type
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../core/services/storage_service.dart';
// import '../models/user_model.dart'; // Removed temporarily

class AuthProvider extends ChangeNotifier {
  // final AuthRepository _authRepository;
  
  User? _currentUser; // Using Supabase User type directly
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(/* this._authRepository */) {
    _init();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  void _init() {
    try {
      final session = SupabaseService.auth.currentSession;
      if (session != null) {
        _currentUser = session.user;
      }
    } catch (e) {
      LoggerService.error('Auth init failed', error: e);
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _currentUser = response.user;
        await StorageService.setString('user_id', response.user!.id);
        LoggerService.info('User logged in successfully');
      }
    } catch (e) {
      _errorMessage = 'خطا در ورود: ${e.toString()}';
      LoggerService.error('Login failed', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.auth.signOut();
      _currentUser = null;
      await StorageService.remove('user_id');
      LoggerService.info('User logged out successfully');
    } catch (e) {
      _errorMessage = 'خطا در خروج: ${e.toString()}';
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