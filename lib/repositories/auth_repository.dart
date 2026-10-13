import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/logger_service.dart';
import '../core/services/supabase_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final _auth = SupabaseService.auth;

  bool get hasActiveSession => _auth.currentSession != null;

  String? get currentUserId => _auth.currentUser?.id;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Restore the current authenticated user and load their database profile.
  Future<UserModel?> getCurrentUser() async {
    final session = _auth.currentSession;

    if (session == null) {
      return null;
    }

    return _mapToUserModel(session.user);
  }

  /// Sign in with email and password.
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null || response.session == null) {
        throw Exception('ورود انجام نشد. لطفاً دوباره تلاش کنید.');
      }

      final model = await _mapToUserModel(user);

      LoggerService.info('User logged in: ${user.id}');

      return model;
    } on AuthException catch (e, st) {
      LoggerService.error(
        'Authentication failed during login',
        error: e,
        stackTrace: st,
      );

      throw Exception(e.message);
    } on PostgrestException catch (e, st) {
      LoggerService.error(
        'Failed to load user profile after login',
        error: e,
        stackTrace: st,
      );

      throw Exception(
        'ورود انجام شد، اما دریافت پروفایل از دیتابیس ناموفق بود. '
        'دسترسی جدول profiles و سیاست‌های RLS را بررسی کنید.',
      );
    } catch (e, st) {
      LoggerService.error(
        'Unexpected login error',
        error: e,
        stackTrace: st,
      );

      if (e is Exception &&
          e.toString().startsWith('Exception: ')) {
        rethrow;
      }

      throw Exception('خطای ناشناخته در زمان ورود');
    }
  }

  /// Register a user.
  ///
  /// This method never grants the admin role.
  /// If email confirmation is enabled, Supabase may return a user
  /// without an active session.
  Future<UserModel> signUp(String email, String password) async {
    try {
      final response = await _auth.signUp(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception(
          'ثبت‌نام ناموفق بود. لطفاً دوباره تلاش کنید.',
        );
      }

      LoggerService.info('User registered: ${user.id}');

      // Email confirmation may be required before a session is created.
      if (response.session == null) {
        LoggerService.info(
          'Registration completed; email confirmation may be required.',
        );

        // No profile lookup is necessary without an authenticated session.
        // The role is deliberately defaulted to customer.
        return _buildUserModel(user, null);
      }

      return await _mapToUserModel(user);
    } on AuthException catch (e, st) {
      LoggerService.error(
        'Authentication failed during registration',
        error: e,
        stackTrace: st,
      );

      throw Exception(e.message);
    } on PostgrestException catch (e, st) {
      LoggerService.error(
        'Failed to load profile after registration',
        error: e,
        stackTrace: st,
      );

      throw Exception(
        'حساب ساخته شد، اما خواندن پروفایل ناموفق بود. '
        'جدول profiles و سیاست‌های RLS را بررسی کنید.',
      );
    } catch (e, st) {
      LoggerService.error(
        'Unexpected registration error',
        error: e,
        stackTrace: st,
      );

      if (e is Exception &&
          e.toString().startsWith('Exception: ')) {
        rethrow;
      }

      throw Exception('خطای ناشناخته در زمان ثبت‌نام');
    }
  }

  /// Sign out the current user.
  Future<void> logout() async {
    try {
      await _auth.signOut();

      LoggerService.info('User logged out successfully');
    } on AuthException catch (e, st) {
      LoggerService.error(
        'Authentication error during logout',
        error: e,
        stackTrace: st,
      );

      throw Exception(e.message);
    } catch (e, st) {
      LoggerService.error(
        'Logout failed',
        error: e,
        stackTrace: st,
      );

      throw Exception('خطا در خروج از حساب کاربری');
    }
  }

  /// Send a password reset email.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email.trim());

      LoggerService.info('Password reset email requested');
    } on AuthException catch (e, st) {
      LoggerService.error(
        'Password reset authentication error',
        error: e,
        stackTrace: st,
      );

      throw Exception(e.message);
    } catch (e, st) {
      LoggerService.error(
        'Password reset failed',
        error: e,
        stackTrace: st,
      );

      throw Exception('خطا در ارسال ایمیل بازنشانی رمز عبور');
    }
  }

  /// Read the user's actual profile from public.profiles.
  ///
  /// The role and status are read exclusively from the database.
  Future<UserModel> _mapToUserModel(User user) async {
    final profile = await _client
        .from('profiles')
        .select(
          'first_name, last_name, phone, avatar_url, role, status',
        )
        .eq('id', user.id)
        .maybeSingle();

    return _buildUserModel(user, profile);
  }

  /// Build a model without trusting user metadata for authorization.
  UserModel _buildUserModel(
    User user,
    Map<String, dynamic>? profile,
  ) {
    final metadata = user.userMetadata ?? <String, dynamic>{};

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      firstName: _asString(profile?['first_name']) ??
          _asString(metadata['first_name']),
      lastName: _asString(profile?['last_name']) ??
          _asString(metadata['last_name']),
      phone: _asString(profile?['phone']) ??
          _asString(user.phone) ??
          _asString(metadata['phone']),
      avatarUrl: _asString(profile?['avatar_url']) ??
          _asString(metadata['avatar_url']),

      // Authorization-sensitive fields come from the database only.
      // Missing profiles must never turn into admin accounts.
      role: _asString(profile?['role']) ?? 'customer',
      status: _asString(profile?['status']) ?? 'active',

      createdAt:
          DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }
}