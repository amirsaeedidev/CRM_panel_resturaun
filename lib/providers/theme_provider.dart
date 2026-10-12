import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/services/logger_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeProvider() {
    _loadThemeFromStorage();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  Future<void> _loadThemeFromStorage() async {
    try {
      final isDark = StorageService.getBool('is_dark_mode');
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e, st) {
      LoggerService.error('Failed to load theme from storage', error: e, stackTrace: st);
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveThemeToStorage();
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      await _saveThemeToStorage();
    }
  }

  Future<void> _saveThemeToStorage() async {
    try {
      await StorageService.setBool('is_dark_mode', _themeMode == ThemeMode.dark);
    } catch (e, st) {
      LoggerService.error('Failed to save theme to storage', error: e, stackTrace: st);
    }
  }
}