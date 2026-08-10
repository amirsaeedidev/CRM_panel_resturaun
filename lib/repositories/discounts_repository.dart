import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/discount_model.dart';

class DiscountsRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of discounts with optional search
  Future<List<DiscountModel>> getDiscounts({
    int page = 1,
    int pageSize = 15,
    String? searchQuery,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      var query = _client.from('discounts').select('*');
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,code.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      return (response as List)
          .map((json) => DiscountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch discounts failed', error: e);
      throw Exception('Error fetching discounts: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch discounts error', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching discounts');
    }
  }

  /// Creates a new discount
  Future<DiscountModel> createDiscount(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('discounts')
          .insert(data)
          .select()
          .single();

      LoggerService.info('Discount created: ${response['id']}');
      return DiscountModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Create discount failed', error: e);
      throw Exception('Error creating discount: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected create discount error', error: e, stackTrace: st);
      throw Exception('Unexpected error creating discount');
    }
  }

  /// Updates an existing discount
  Future<DiscountModel> updateDiscount(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('discounts')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      LoggerService.info('Discount updated: $id');
      return DiscountModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Update discount failed', error: e);
      throw Exception('Error updating discount: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update discount error', error: e, stackTrace: st);
      throw Exception('Unexpected error updating discount');
    }
  }

  /// Deletes a discount permanently
  Future<void> deleteDiscount(String id) async {
    try {
      await _client.from('discounts').delete().eq('id', id);
      LoggerService.info('Discount deleted: $id');
    } on PostgrestException catch (e) {
      LoggerService.error('Delete discount failed', error: e);
      throw Exception('Error deleting discount: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected delete discount error', error: e, stackTrace: st);
      throw Exception('Unexpected error deleting discount');
    }
  }
}