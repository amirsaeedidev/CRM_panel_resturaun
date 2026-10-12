
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/order_model.dart';

class OrdersRepository {
  final SupabaseClient _client;

  OrdersRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Fetches paginated orders from orders_view.
  ///
  /// Supports:
  /// - Pagination
  /// - Search by order ID, customer name, and phone
  /// - Filtering by order status
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? status,
  }) async {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Must be greater than 0');
    }

    if (pageSize < 1) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'Must be greater than 0',
      );
    }

    try {
      final start = (page - 1) * pageSize;
      final end = start + pageSize - 1;

      var query = _client.from('orders_view').select('*');

      final normalizedStatus = status?.trim();
      if (normalizedStatus != null && normalizedStatus.isNotEmpty) {
        query = query.eq('status', normalizedStatus);
      }

      final normalizedSearch = searchQuery?.trim();
      if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
        // Escape characters that have special meaning in PostgREST filters.
        final escapedSearch = normalizedSearch
            .replaceAll(r'\', r'\\')
            .replaceAll(',', r'\,')
            .replaceAll('(', r'\(')
            .replaceAll(')', r'\)')
            .replaceAll('.', r'\.')
            .replaceAll('"', r'\"');

        query = query.or(
          'id.ilike.%$escapedSearch%,'
          'customer_name.ilike.%$escapedSearch%,'
          'customer_phone.ilike.%$escapedSearch%',
        );
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      return response
          .map<OrderModel>(
            (json) => OrderModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on PostgrestException catch (e, st) {
      LoggerService.error(
        'Fetch orders failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      LoggerService.error(
        'Unexpected fetch orders error',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Fetches a single order by its ID.
  Future<OrderModel> getOrderById(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Order ID cannot be empty');
    }

    try {
      final response = await _client
          .from('orders_view')
          .select('*')
          .eq('id', id)
          .single();

      return OrderModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    } on PostgrestException catch (e, st) {
      LoggerService.error(
        'Fetch order by ID failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      LoggerService.error(
        'Unexpected fetch order error',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Updates an order's status in the base orders table.
  Future<void> updateOrderStatus(
    String id,
    String newStatus,
  ) async {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Order ID cannot be empty');
    }

    if (newStatus.trim().isEmpty) {
      throw ArgumentError.value(
        newStatus,
        'newStatus',
        'Order status cannot be empty',
      );
    }

    try {
      await _client
          .from('orders')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);

      LoggerService.info('Order status updated: $id to $newStatus');
    } on PostgrestException catch (e, st) {
      LoggerService.error(
        'Update order status failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } catch (e, st) {
      LoggerService.error(
        'Unexpected update order status error',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
