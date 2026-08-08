import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/services/logger_service.dart';
import '../models/product_model.dart';

class ProductsRepository {
  final _client = SupabaseService.client;

  /// Fetches a paginated list of products with optional search
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    String? categoryId,
  }) async {
    try {
      int start = (page - 1) * pageSize;
      int end = start + pageSize - 1;

      var query = _client.from('products').select('*');
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(start, end);

      return (response as List)
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch products failed', error: e);
      throw Exception('خطا در دریافت محصولات: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch products error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت محصولات');
    }
  }

  /// Fetches a single product by its ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('id', id)
          .single();

      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Fetch product by id failed', error: e);
      throw Exception('خطا در دریافت اطلاعات محصول: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected fetch product error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در دریافت محصول');
    }
  }

  /// Creates a new product
  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('products')
          .insert(data)
          .select()
          .single();

      LoggerService.info('Product created: ${response['id']}');
      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Create product failed', error: e);
      throw Exception('خطا در ایجاد محصول: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected create product error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در ایجاد محصول');
    }
  }

  /// Updates an existing product
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('products')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      LoggerService.info('Product updated: $id');
      return ProductModel.fromJson(response);
    } on PostgrestException catch (e) {
      LoggerService.error('Update product failed', error: e);
      throw Exception('خطا در ویرایش محصول: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected update product error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در ویرایش محصول');
    }
  }

  /// Deletes a product permanently
  Future<void> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
      LoggerService.info('Product deleted: $id');
    } on PostgrestException catch (e) {
      LoggerService.error('Delete product failed', error: e);
      throw Exception('خطا در حذف محصول: ${e.message}');
    } catch (e, st) {
      LoggerService.error('Unexpected delete product error', error: e, stackTrace: st);
      throw Exception('خطای ناشناخته در حذف محصول');
    }
  }
}