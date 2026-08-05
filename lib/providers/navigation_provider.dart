import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentRoute = AppRoutes.dashboard;
  int _selectedIndex = 0;

  String get currentRoute => _currentRoute;
  int get selectedIndex => _selectedIndex;

  void updateNavigation(String route) {
    if (_currentRoute != route) {
      _currentRoute = route;
      _selectedIndex = _getIndexByRoute(route);
      notifyListeners();
    }
  }

  void updateIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      _currentRoute = _getRouteByIndex(index);
      notifyListeners();
    }
  }

  int _getIndexByRoute(String route) {
    switch (route) {
      case AppRoutes.dashboard:
        return 0;
      case AppRoutes.orders:
        return 1;
      case AppRoutes.products:
        return 2;
      case AppRoutes.customers:
        return 3;
      case AppRoutes.categories:
        return 4;
      case AppRoutes.reports:
        return 5;
      case AppRoutes.settings:
        return 6;
      default:
        return 0;
    }
  }

  String _getRouteByIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.dashboard;
      case 1:
        return AppRoutes.orders;
      case 2:
        return AppRoutes.products;
      case 3:
        return AppRoutes.customers;
      case 4:
        return AppRoutes.categories;
      case 5:
        return AppRoutes.reports;
      case 6:
        return AppRoutes.settings;
      default:
        return AppRoutes.dashboard;
    }
  }
}