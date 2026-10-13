import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/logger_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  StreamSubscription<AuthState>? _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = true;
  bool _disposed = false;

  String? _errorMessage;
  String? _infoMessage;

  AuthProvider(this._authRepository) {
    _listenToAuthChanges();
  }

  UserModel? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  bool get isAuthenticated =>
      _currentUser != null && _authRepository.hasActiveSession;

  bool get isAdmin => _currentUser?.isAdmin ?? false;

  String? get errorMessage => _errorMessage;

  String? get infoMessage => _infoMessage;

  /// Listen for session restoration, login, logout, and token refresh events.
  void _listenToAuthChanges() {
    _authSubscription = _authRepository.authStateChanges.listen(
      (state) {
        unawaited(_handleAuthStateChange(state));
      },
      onError: (Object error, StackTrace stackTrace) {
        LoggerService.error(
          'Auth state stream error',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  Future<void> _handleAuthStateChange(AuthState state) async {
    if (_disposed) return;

    final session = state.session;

    if (session == null) {
      _currentUser = null;
      _isLoading = false;

      await _removeStoredUserId();

      _notifyIfAlive();
      return;
    }

    try {
      final user = await _authRepository.getCurrentUser();

      if (_disposed) return;

      // Avoid applying a stale profile if the account changed mid-request.
      if (_authRepository.currentUserId != session.user.id) {
        return;
      }

      _currentUser = user;

      if (user != null) {
        await _storeUserId(user.id);
      } else {
        await _removeStoredUserId();
      }

      LoggerService.info('Authentication state synchronized');
    } catch (e, st) {
      LoggerService.error(
        'Failed to restore or synchronize user profile',
        error: e,
        stackTrace: st,
      );

      _currentUser = null;
      _errorMessage = _readableError(e);

      await _removeStoredUserId();
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notifyIfAlive();
      }
    }
  }

  /// Login using real Supabase authentication.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    _notifyIfAlive();

    try {
      final user = await _authRepository.login(email, password);

      if (_disposed) return;

      _currentUser = user;
      await _storeUserId(user.id);

      LoggerService.info('User logged in successfully');
    } catch (e, st) {
      _errorMessage = _readableError(e);

      LoggerService.error(
        'Login failed',
        error: e,
        stackTrace: st,
      );
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notifyIfAlive();
      }
    }
  }

  /// Register a new account.
  ///
  /// If email confirmation is required, the app stays unauthenticated
  /// and displays an informational message.
  Future<void> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    _notifyIfAlive();

    try {
      await _authRepository.signUp(email, password);

      if (_disposed) return;

      if (_authRepository.hasActiveSession) {
        final user = await _authRepository.getCurrentUser();

        if (_disposed) return;

        if (user == null) {
          throw Exception(
            'حساب ایجاد شد، اما نشست ورود قابل بازیابی نیست.',
          );
        }

        _currentUser = user;
        await _storeUserId(user.id);

        LoggerService.info(
          'User registered with an active session',
        );
      } else {
        // Account creation is not the same as being signed in.
        _currentUser = null;
        await _removeStoredUserId();

        _infoMessage =
            'ثبت‌نام انجام شد. برای ورود، ایمیل خود را تأیید کنید.';
      }
    } catch (e, st) {
      _errorMessage = _readableError(e);

      LoggerService.error(
        'Registration failed',
        error: e,
        stackTrace: st,
      );
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notifyIfAlive();
      }
    }
  }

  /// Sign out from Supabase.
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    _infoMessage = null;
    _notifyIfAlive();

    try {
      await _authRepository.logout();

      if (_disposed) return;

      _currentUser = null;
      await _removeStoredUserId();

      LoggerService.info('User logged out successfully');
    } catch (e, st) {
      _errorMessage = _readableError(e);

      LoggerService.error(
        'Logout failed',
        error: e,
        stackTrace: st,
      );
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _notifyIfAlive();
      }
    }
  }

  Future<void> _storeUserId(String userId) async {
    try {
      await StorageService.setString('user_id', userId);
    } catch (e, st) {
      // Supabase's session remains the source of authentication truth.
      LoggerService.error(
        'Failed to cache user ID',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _removeStoredUserId() async {
    try {
      await StorageService.remove('user_id');
    } catch (e, st) {
      LoggerService.error(
        'Failed to remove cached user ID',
        error: e,
        stackTrace: st,
      );
    }
  }

  String _readableError(Object error) {
    final message = error.toString();
    const prefix = 'Exception: ';

    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }

    return message;
  }

  void clearError() {
    _errorMessage = null;
    _notifyIfAlive();
  }

  void clearInfo() {
    _infoMessage = null;
    _notifyIfAlive();
  }

  void _notifyIfAlive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }
}