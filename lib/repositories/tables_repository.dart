import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/table_model.dart';

class TablesRepository {
  final _client = SupabaseService.client;

  /// Fetches all restaurant tables
  Future<List<TableModel>> getTables() async {
    try {
      final response = await _client
          .from('tables')
          .select('*')
          .order('table_number', ascending: true);

      return (response as List)
          .map((json) => TableModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch tables failed', error: e);
      throw Exception('Error fetching tables: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch tables error', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching tables');
    }
  }

  /// Updates the status and current order of a table
  Future<void> updateTableStatus(String id, String status, String? currentOrderId) async {
    try {
      final data = {
        'status': status,
        'current_order_id': currentOrderId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      
      await _client.from('tables').update(data).eq('id', id);
      LoggerService.info('Table status updated: $id to $status');
    } on PostgrestException catch (e) {
      LoggerService.error('Update table status failed', error: e);
      throw Exception('Error updating table status: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update table status error', error: e, stackTrace: st);
      throw Exception('Unexpected error updating table status');
    }
  }
}