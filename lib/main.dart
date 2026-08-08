import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/logger_service.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize local storage (SharedPreferences)
    await StorageService.initialize();
    
    // TODO: Load .env file here later when connecting to Supabase
    // await dotenv.load(fileName: ".env");
    
    LoggerService.info('Application starting...');
  } catch (e, st) {
    LoggerService.error('Initialization failed', error: e, stackTrace: st);
  }

  runApp(const CrmApp());
}