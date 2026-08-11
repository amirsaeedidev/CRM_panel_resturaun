import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';
import '../core/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  // State
  Color _primaryColor = const Color(0xFF2563EB); // Default Blue
  Color _secondaryColor = const Color(0xFF0EA5E9); // Default Sky
  double? _minDeliveryAmount;
  double? _fixedDeliveryFee;
  bool _isLoading = false;

  // Getters
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  double? get minDeliveryAmount => _minDeliveryAmount;
  double? get fixedDeliveryFee => _fixedDeliveryFee;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final pColorValue = StorageService.getInt('primary_color');
      final sColorValue = StorageService.getInt('secondary_color');
      
      if (pColorValue != null) _primaryColor = Color(pColorValue);
      if (sColorValue != null) _secondaryColor = Color(sColorValue);
      
      _minDeliveryAmount = StorageService.getDouble('min_delivery_amount');
      _fixedDeliveryFee = StorageService.getDouble('fixed_delivery_fee');
      
      notifyListeners();
    } catch (e, st) {
      LoggerService.error('Load settings failed', error: e, stackTrace: st);
    }
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    StorageService.setInt('primary_color', color.value);
    notifyListeners();
  }

  void setSecondaryColor(Color color) {
    _secondaryColor = color;
    StorageService.setInt('secondary_color', color.value);
    notifyListeners();
  }

  Future<void> saveSettings(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      _minDeliveryAmount = data['min_delivery_amount'] as double;
      _fixedDeliveryFee = data['fixed_delivery_fee'] as double;

      await StorageService.setDouble('min_delivery_amount', _minDeliveryAmount!);
      await StorageService.setDouble('fixed_delivery_fee', _fixedDeliveryFee!);
      
      // In a real app, you would also call a Repository to save to Supabase here
      // await _repository.saveSettings(data);
      
    } catch (e, st) {
      LoggerService.error('Save settings failed', error: e, stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}