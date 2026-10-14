import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/services/logger_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/supabase_service.dart';
import 'providers/notifications_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? startupError;

  // 1. Initialize local storage.
  try {
    await StorageService.initialize();
    LoggerService.info('Local storage initialized successfully');
  } catch (e, st) {
    LoggerService.error(
      'Local storage initialization failed',
      error: e,
      stackTrace: st,
    );

    startupError = 'راه‌اندازی فضای ذخیره‌سازی ناموفق بود.';
  }

  // 2. Load environment variables.
  // Missing .env is not immediately fatal; Supabase initialization
  // below determines whether the app can safely continue.
  try {
    await dotenv.load(fileName: '.env');
    LoggerService.info('Environment variables loaded successfully');
  } catch (e) {
    LoggerService.warning(
      '.env file not found. Checking Supabase configuration...',
    );
  }

  // 3. Initialize Supabase only if storage initialization succeeded.
  if (startupError == null) {
    try {
      await SupabaseService.initialize();
      LoggerService.info('Supabase initialized successfully');
    } catch (e, st) {
      LoggerService.error(
        'Supabase initialization failed',
        error: e,
        stackTrace: st,
      );

      startupError =
          'اتصال به Supabase برقرار نشد. تنظیمات .env، '
          'آدرس پروژه و Publishable Key را بررسی کنید.';
    }
  }

  // 4. Do not create providers that depend on Supabase
  // if initialization failed.
  if (startupError != null) {
    runApp(StartupErrorApp(message: startupError));
    return;
  }

  // 5. Register NotificationsProvider above the entire application.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(),
        ),

        // Keep other existing root-level providers here if needed.
      ],
      child: const CrmApp(),
    ),
  );

  LoggerService.info('Application started successfully');
}

/// A simple startup error screen that does not depend on Supabase.
class StartupErrorApp extends StatelessWidget {
  final String message;

  const StartupErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'راه‌اندازی برنامه ناموفق بود',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'خطای دقیق‌تر را در لاگ برنامه بررسی کنید.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
