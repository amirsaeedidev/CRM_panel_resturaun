import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/statistics_model.dart';

class StatisticsRepository {
  final _client = SupabaseService.client;

  /// Fetches Key Performance Indicators (KPIs) for a specific period
  Future<StatisticsModel> getKpiStatistics({
    String period = 'monthly', // e.g., 'daily', 'weekly', 'monthly', 'yearly'
  }) async {
    try {
      // Assumes an RPC function 'get_kpi_statistics' exists in Supabase
      final response = await _client.rpc(
        'get_kpi_statistics',
        params: {'p_period': period},
      );

      return StatisticsModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch KPI statistics failed', error: e);
      throw Exception('خطا در دریافت شاخص‌های عملکرد: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch KPI statistics error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت شاخص‌های عملکرد');
    }
  }

  /// Fetches sales trend data for line charts (e.g., last 7 days or 12 months)
  Future<List<Map<String, dynamic>>> getSalesTrend({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Assumes an RPC function 'get_sales_trend' exists in Supabase
      final response = await _client.rpc(
        'get_sales_trend',
        params: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return (response as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch sales trend failed', error: e);
      throw Exception('خطا در دریافت روند فروش: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch sales trend error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت روند فروش');
    }
  }
}