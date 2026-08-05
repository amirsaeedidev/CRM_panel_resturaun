import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/services/logger_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool _hasBeenCalled = false;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _hasBeenCalled = true;
      final currentlyConnected = !result.contains(ConnectivityResult.none);
      
      if (_isConnected != currentlyConnected) {
        _isConnected = currentlyConnected;
        LoggerService.info('Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
        notifyListeners();
      }
    });

    // Check initial state immediately
    Connectivity().checkConnectivity().then((List<ConnectivityResult> result) {
      if (!_hasBeenCalled) {
        _isConnected = !result.contains(ConnectivityResult.none);
        notifyListeners();
      }
    });
  }
}