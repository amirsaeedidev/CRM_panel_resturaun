import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/order_model.dart';

class OrdersRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of orders with optional search and status filter
  /// Uses 'orders_view' to get joined customer data (name & phone)
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? status,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      // Changed from 'orders' to 'orders_view'
      var query = _client.from('orders_view').select('*');
      
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Now we can search directly by customer_name or phone since they are in the view!
        query = query.or('id.ilike.%$searchQuery%,customer_name.ilike.%$searchQuery%,customer_phone.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch orders failed', error: e);
      throw Exception('Error fetching orders: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch orders error', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching orders');
    }
  }

  /// Fetches a single order by its ID
  /// Uses 'orders_view' to get joined customer data for the details page
  Future<OrderModel> getOrderById(String id) async {
    try {
      // Changed from 'orders' to 'orders_view'
      final response = await _client
          .from('orders_view')
          .select('*')
          .eq('id', id)
          .single();

      return OrderModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch order by id failed', error: e);
      throw Exception('Error fetching order details: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch order error', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching order details');
    }
  }

  /// Updates the status of an order
  /// Note: Updates must still target the base 'orders' table, not the view
  Future<void> updateOrderStatus(String id, String newStatus) async {
    try {
      await _client
          .from('orders') // Target the base table for updates
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);

      LoggerService.info('Order status updated: $id to $newStatus');
    } on PostgrestException catch (e) {
      LoggerService.error('Update order status failed', error: e);
      throw Exception('Error updating order status: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update order status error', error: e, stackTrace: st);
      throw Exception('Unexpected error updating order status');
    }
  }
}