import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/banner_model.dart';

class BannersRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of banners with optional search
  Future<List<BannerModel>> getBanners({
    int page = 1,
    int pageSize = 15,
    String? searchQuery,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      var query = _client.from('banners').select('*');
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      final response = await query
          .order('display_order', ascending: true)
          .range(start, end);

      return (response as List)
          .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch banners failed', error: e);
      throw Exception('Error fetching banners: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch banners error', error: e, stackTrace: st);
      throw Exception('Unexpected error fetching banners');
    }
  }

  /// Creates a new banner
  Future<BannerModel> createBanner(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('banners')
          .insert(data)
          .select()
          .single();

      LoggerService.info('Banner created: ${response['id']}');
      return BannerModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Create banner failed', error: e);
      throw Exception('Error creating banner: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected create banner error', error: e, stackTrace: st);
      throw Exception('Unexpected error creating banner');
    }
  }

  /// Updates an existing banner
  Future<BannerModel> updateBanner(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('banners')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      LoggerService.info('Banner updated: $id');
      return BannerModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Update banner failed', error: e);
      throw Exception('Error updating banner: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update banner error', error: e, stackTrace: st);
      throw Exception('Unexpected error updating banner');
    }
  }

  /// Deletes a banner permanently
  Future<void> deleteBanner(String id) async {
    try {
      await _client.from('banners').delete().eq('id', id);
      LoggerService.info('Banner deleted: $id');
    } on PostgrestException catch (e) {
      LoggerService.error('Delete banner failed', error: e);
      throw Exception('Error deleting banner: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected delete banner error', error: e, stackTrace: st);
      throw Exception('Unexpected error deleting banner');
    }
  }
}