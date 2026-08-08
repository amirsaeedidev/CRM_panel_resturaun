import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/statistics_model.dart';
import '../models/order_model.dart';

class DashboardRepository {
  final _client = SupabaseService.client;

  /// Fetches aggregated statistics for the dashboard cards
  Future<StatisticsModel> getStatistics() async {
    try {
      // Assumes you have an RPC function named 'get_dashboard_stats' in Supabase
      // that returns a JSON object with total_sales, total_orders, etc.
      final response = await _client.rpc('get_dashboard_stats');

      return StatisticsModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch dashboard stats failed', error: e);
      throw Exception('خطا در دریافت آمار داشبورد: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch dashboard stats error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت آمار داشبورد');
    }
  }

  /// Fetches recent orders for the dashboard list
  Future<List<OrderModel>> getRecentOrders({int limit = 5}) async {
    try {
      final response = await _client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch recent orders failed', error: e);
      throw Exception('خطا در دریافت آخرین سفارشات: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch recent orders error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت آخرین سفارشات');
    }
  }
}