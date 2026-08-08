import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/order_model.dart';

class OrdersRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of orders with optional search and status filter
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? status,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      var query = _client.from('orders').select('*');
      
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('id.ilike.%$searchQuery%,customer_name.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch orders failed', error: e);
      throw Exception('خطا در دریافت سفارشات: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch orders error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت سفارشات');
    }
  }

  /// Fetches a single order by its ID
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _client
          .from('orders')
          .select('*')
          .eq('id', id)
          .single();

      return OrderModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch order by id failed', error: e);
      throw Exception('خطا در دریافت اطلاعات سفارش: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch order error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت سفارش');
    }
  }

  /// Updates the status of an order
  Future<void> updateOrderStatus(String id, String newStatus) async {
    try {
      await _client
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);

      LoggerService.info('Order status updated: $id to $newStatus');
    } on PostgrestException catch (e) {
      LoggerService.error('Update order status failed', error: e);
      throw Exception('خطا در تغییر وضعیت سفارش: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update order status error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در تغییر وضعیت سفارش');
    }
  }
}