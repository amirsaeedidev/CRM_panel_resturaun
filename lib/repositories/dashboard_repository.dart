import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/logger_service.dart';
import '../core/services/supabase_service.dart';
import '../models/statistics_model.dart';
import '../models/order_model.dart';

class DashboardRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// Fetch dashboard statistics from the real Supabase RPC.
  Future<StatisticsModel> getStatistics() async {
    try {
      final dynamic response = await _client.rpc('get_dashboard_stats');

      if (response is! Map) {
        throw FormatException(
          'پاسخ تابع get_dashboard_stats باید یک JSON object باشد؛ '
          'نوع دریافت‌شده: ${response.runtimeType}',
        );
      }

      final json = Map<String, dynamic>.from(response);

      return StatisticsModel.fromJson(json);
    } on PostgrestException catch (e, st) {
      LoggerService.error(
        'Fetch dashboard statistics failed',
        error: e,
        stackTrace: st,
      );

      if (e.message.contains('Administrator access required')) {
        throw Exception(
          'دسترسی به آمار داشبورد مجاز نیست. '
          'نقش ادمین، وضعیت حساب و نشست ورود را بررسی کنید.',
        );
      }

      throw Exception(
        'خطا در دریافت آمار داشبورد '
        '(کد ${e.code ?? 'نامشخص'}): ${e.message}',
      );
    } on FormatException catch (e, st) {
      LoggerService.error(
        'Invalid dashboard statistics response',
        error: e,
        stackTrace: st,
      );

      throw Exception(e.message);
    } catch (e, st) {
      LoggerService.error(
        'Unexpected dashboard statistics error',
        error: e,
        stackTrace: st,
      );

      throw Exception('خطا در پردازش آمار داشبورد: $e');
    }
  }

  /// Fetch the most recent orders from the real database.
  Future<List<OrderModel>> getRecentOrders({int limit = 5}) async {
    final safeLimit = limit.clamp(1, 100).toInt();

    try {
      final dynamic response = await _client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false)
          .limit(safeLimit);

      if (response is! List) {
        throw const FormatException('پاسخ سفارش‌های اخیر باید یک لیست باشد.');
      }

      return response
          .map<OrderModel>((row) {
            if (row is! Map) {
              throw const FormatException(
                'ساختار یکی از سفارش‌های دریافتی معتبر نیست.',
              );
            }

            final json = Map<String, dynamic>.from(row);

            return OrderModel.fromJson(json);
          })
          .toList(growable: false);
    } on PostgrestException catch (e, st) {
      LoggerService.error(
        'Fetch recent orders failed',
        error: e,
        stackTrace: st,
      );

      throw Exception(
        'خطا در دریافت سفارش‌های اخیر '
        '(کد ${e.code ?? 'نامشخص'}): ${e.message}',
      );
    } on FormatException catch (e, st) {
      LoggerService.error(
        'Invalid recent orders response',
        error: e,
        stackTrace: st,
      );

      throw Exception(e.message);
    } catch (e, st) {
      LoggerService.error(
        'Unexpected recent orders error',
        error: e,
        stackTrace: st,
      );

      throw Exception('خطا در پردازش سفارش‌های اخیر: $e');
    }
  }
}
