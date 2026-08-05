import 'dart:developer' as developer;
import '../config/app_config.dart';

class LoggerService {
  LoggerService._();

  static void debug(String message, {String? name}) {
    if (AppConfig.enableLogging) {
      developer.log(message, name: name ?? 'CRM_Debug', level: 500);
    }
  }

  static void info(String message, {String? name}) {
    if (AppConfig.enableLogging) {
      developer.log(message, name: name ?? 'CRM_Info', level: 800);
    }
  }

  static void warning(String message, {String? name}) {
    if (AppConfig.enableLogging) {
      developer.log(message, name: name ?? 'CRM_Warning', level: 900);
    }
  }

  static void error(String message, {String? name, Object? error, StackTrace? stackTrace}) {
    if (AppConfig.enableLogging) {
      developer.log(
        message,
        name: name ?? 'CRM_Error',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}