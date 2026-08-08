import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/category_model.dart';

class CategoriesRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of categories with optional search
  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      var query = _client.from('categories').select('*');
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      return (response as List)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch categories failed', error: e);
      throw Exception('خطا در دریافت دسته‌بندی‌ها: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch categories error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت دسته‌بندی‌ها');
    }
  }

  /// Creates a new category
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('categories')
          .insert(data)
          .select()
          .single();

      LoggerService.info('Category created: ${response['id']}');
      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Create category failed', error: e);
      throw Exception('خطا در ایجاد دسته‌بندی: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected create category error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در ایجاد دسته‌بندی');
    }
  }

  /// Updates an existing category
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('categories')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      LoggerService.info('Category updated: $id');
      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Update category failed', error: e);
      throw Exception('خطا در ویرایش دسته‌بندی: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update category error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در ویرایش دسته‌بندی');
    }
  }

  /// Deletes a category permanently
  Future<void> deleteCategory(String id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
      LoggerService.info('Category deleted: $id');
    } on PostgrestException catch (e) {
      LoggerService.error('Delete category failed', error: e);
      throw Exception('خطا در حذف دسته‌بندی: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected delete category error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در حذف دسته‌بندی');
    }
  }
}