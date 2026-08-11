import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/report_model.dart';

class ReportsRepository {
  final _client = SupabaseService.client;

  /// Fetches sales report (e.g., monthly sales for bar chart)
  Future<ReportModel> getSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client.rpc(
        'get_sales_report',
        params: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      return ReportModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch sales report failed', error: e);
      throw Exception('خطا در دریافت گزارش فروش: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch sales report error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت گزارش فروش');
    }
  }

  /// Fetches top-selling products report
  Future<ReportModel> getTopProductsReport({int limit = 10}) async {
    try {
      final response = await _client.rpc(
        'get_top_products',
        params: {'limit_count': limit},
      );

      return ReportModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch top products report failed', error: e);
      throw Exception('خطا در دریافت گزارش محصولات پرفروش: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch top products error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت گزارش محصولات');
    }
  }

  /// Fetches customer distribution report (e.g., for pie chart)
  Future<ReportModel> getCustomerDistributionReport() async {
    try {
      final response = await _client.rpc('get_customer_distribution');

      return ReportModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch customer distribution failed', error: e);
      throw Exception('خطا در دریافت توزیع مشتریان: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch customer distribution error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت توزیع مشتریان');
    }
  }
}