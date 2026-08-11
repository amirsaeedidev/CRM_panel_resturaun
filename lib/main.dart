import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'core/services/logger_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Initialize local storage (SharedPreferences)
    await StorageService.initialize();
    
    // 2. Load environment variables
    // We use try-catch here so the app doesn't crash if .env is missing during UI development
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      LoggerService.warning('.env file not found. Supabase will use placeholder values.');
    }
    
    // 3. Initialize Supabase
    // SupabaseConfig handles empty strings gracefully if .env is missing
    await SupabaseService.initialize();
    
    LoggerService.info('Application starting...');
  } catch (e, st) {
    LoggerService.error('Initialization failed', error: e, stackTrace: st);
  }

  runApp(const CrmApp());
}