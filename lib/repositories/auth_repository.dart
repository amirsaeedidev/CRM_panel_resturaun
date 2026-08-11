import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final _auth = SupabaseService.auth;

  /// Get current session and user
  UserModel? getCurrentUser() {
    final session = _auth.currentSession;
    if (session?.user != null) {
      return _mapToUserModel(session!.user);
    }
    return null;
  }

  /// Login with email and password
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('کاربر یافت نشد');
      }
      
      LoggerService.info('User logged in: ${response.user!.id}');
      return _mapToUserModel(response.user!);
    } on AuthException catch (e) {
      LoggerService.error('AuthException during login', error: e);
      throw Exception(e.message);
    } catch (e, st) {
      LoggerService.error('Unexpected login error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در زمان ورود');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      LoggerService.info('User logged out successfully');
    } catch (e, st) {
      LoggerService.error('Logout failed', error: e, stackTrace: st);
      throw Exception('خطا در خروج از حساب کاربری');
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
      LoggerService.info('Password reset email sent to $email');
    } on AuthException catch (e) {
      LoggerService.error('AuthException during reset password', error: e);
      throw Exception(e.message);
    } catch (e, st) {
      LoggerService.error('Unexpected reset password error', error: e, stackTrace: st);
      throw Exception('خطا در ارسال ایمیل بازنشانی رمز عبور');
    }
  }

  /// Helper method to map Supabase User to UserModel
  UserModel _mapToUserModel(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      firstName: metadata['first_name'] as String?,
      lastName: metadata['last_name'] as String?,
      phone: metadata['phone'] as String? ?? user.phone,
      avatarUrl: metadata['avatar_url'] as String?,
      role: metadata['role'] as String? ?? 'user',
      createdAt: DateTime.parse(user.createdAt),
    );
  }
}