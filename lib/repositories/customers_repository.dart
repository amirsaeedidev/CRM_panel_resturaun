import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/user_model.dart';

class CustomersRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of customers with optional search
  Future<List<UserModel>> getCustomers({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      var query = _client
          .from('users')
          .select('*')
          .eq('role', 'user'); // Only fetch users with 'user' role

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('first_name.ilike.%$searchQuery%,last_name.ilike.%$searchQuery%,email.ilike.%$searchQuery%,phone.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      return (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch customers failed', error: e);
      throw Exception('خطا در دریافت مشتریان: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch customers error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت مشتریان');
    }
  }

  /// Fetches a single customer profile by ID
  Future<UserModel> getCustomerById(String id) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', id)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch customer by id failed', error: e);
      throw Exception('خطا در دریافت اطلاعات مشتری: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch customer error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت مشتری');
    }
  }

  /// Updates customer status (e.g., active, blocked)
  Future<void> updateCustomerStatus(String id, String status) async {
    try {
      await _client
          .from('users')
          .update({'status': status})
          .eq('id', id);

      LoggerService.info('Customer status updated: $id to $status');
    } on PostgrestException catch (e) {
      LoggerService.error('Update customer status failed', error: e);
      throw Exception('خطا در تغییر وضعیت مشتری: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update customer status error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در تغییر وضعیت مشتری');
    }
  }
}