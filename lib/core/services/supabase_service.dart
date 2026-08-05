import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'logger_service.dart';

class SupabaseService {
  SupabaseService._();

  static late SupabaseClient client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        debug: true,
      );
      client = Supabase.instance.client;
      LoggerService.info('Supabase initialized successfully');
    } catch (e, st) {
      LoggerService.error('Supabase initialization failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // Auth Helpers
  static GoTrueClient get auth => client.auth;
  
  // Database Helpers
  static SupabaseQueryBuilder from(String table) => client.from(table);

  // Storage Helpers
  static SupabaseStorageClient get storage => client.storage;

  // Realtime Helpers
  static RealtimeClient get realtime => client.realtime;
}