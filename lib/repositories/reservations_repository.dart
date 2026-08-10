import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/reservation_model.dart';

class ReservationsRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of reservations with optional search and status filter
  Future<List<ReservationModel>> getReservations({
    int page = 1,
    int pageSize = 15,
    String? searchQuery,
    String? status,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      var query = _client.from('reservations').select('*');
      
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('customer_name.ilike.%$searchQuery%,customer_phone.ilike.%$searchQuery%');
      }

      final response = await query
          .order('date', ascending: false)
          .range(start, end);

      return (response as List)
          .map((json) => ReservationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch reservations failed', error: e);
      throw Exception('Error fetching reservations: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch reservations error', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching reservations');
    }
  }

  /// Updates the status of a reservation
  Future<void> updateReservationStatus(String id, String newStatus) async {
    try {
      await _client
          .from('reservations')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', id);

      LoggerService.info('Reservation status updated: $id to $newStatus');
    } on PostgrestException catch (e) {
      LoggerService.error('Update reservation status failed', error: e);
      throw Exception('Error updating reservation status: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update reservation status error', error: e, stackTrace: st);
      throw Exception('Unexpected error updating reservation status');
    }
  }
}