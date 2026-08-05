import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    LoggerService.info('SharedPreferences initialized successfully');
  }

  // Setter methods
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  // Getter methods
  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Remove & Clear
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  static Future<bool> clear() async {
    return await _prefs.clear();
  }
}