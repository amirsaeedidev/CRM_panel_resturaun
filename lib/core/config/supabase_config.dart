import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Bucket اصلی برای بنرها، محصولات و...
  static String get storageBucket => dotenv.env['SUPABASE_STORAGE_BUCKET'] ?? 'crm-assets';
  
  // Bucket اختصاصی برای آیکون‌های دسته‌بندی
  static String get categoryIconsBucket => dotenv.env['SUPABASE_CATEGORY_ICONS_BUCKET'] ?? 'category-icons';
}