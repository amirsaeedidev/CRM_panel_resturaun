import 'package:flutter/material.dart';

/// Centralized route path constants
/// 
/// All route paths are defined here to avoid magic strings
/// and ensure consistency across the application.
class AppRoutes {
  AppRoutes._();

  // Root route
  static const String root = '/';

  // Main shell route
  static const String shell = '/app';

  // Dashboard
  static const String dashboard = '/dashboard';
  
  // Orders
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  
  // Products
  static const String products = '/products';
  static const String productCreate = '/products/create';
  static const String productEdit = '/products/:id/edit';
  static const String productDetails = '/products/:id';
  
  // Categories
  static const String categories = '/categories';
  static const String categoryCreate = '/categories/create';
  static const String categoryEdit = '/categories/:id/edit';
  
  // Customers
  static const String customers = '/customers';
  static const String customerDetails = '/customers/:id';
  
  // Discounts
  static const String discounts = '/discounts';
  static const String discountCreate = '/discounts/create';
  static const String discountEdit = '/discounts/:id/edit';
  
  // Reports
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String inventoryReport = '/reports/inventory';
  
  // Statistics
  static const String statistics = '/statistics';
  
  // Notifications
  static const String notifications = '/notifications';
  
  // Settings
  static const String settings = '/settings';
  static const String settingsGeneral = '/settings/general';
  static const String settingsSecurity = '/settings/security';
  static const String settingsAppearance = '/settings/appearance';
  
  // Profile
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';

  /// Get full path for a route
  static String getPath(String routeName) {
    switch (routeName) {
      case 'root':
        return root;
      case 'shell':
        return shell;
      case 'dashboard':
        return dashboard;
      case 'orders':
        return orders;
      case 'orderDetails':
        return orderDetails;
      case 'products':
        return products;
      case 'productCreate':
        return productCreate;
      case 'productEdit':
        return productEdit;
      case 'productDetails':
        return productDetails;
      case 'categories':
        return categories;
      case 'categoryCreate':
        return categoryCreate;
      case 'categoryEdit':
        return categoryEdit;
      case 'customers':
        return customers;
      case 'customerDetails':
        return customerDetails;
      case 'discounts':
        return discounts;
      case 'discountCreate':
        return discountCreate;
      case 'discountEdit':
        return discountEdit;
      case 'reports':
        return reports;
      case 'salesReport':
        return salesReport;
      case 'inventoryReport':
        return inventoryReport;
      case 'statistics':
        return statistics;
      case 'notifications':
        return notifications;
      case 'settings':
        return settings;
      case 'settingsGeneral':
        return settingsGeneral;
      case 'settingsSecurity':
        return settingsSecurity;
      case 'settingsAppearance':
        return settingsAppearance;
      case 'profile':
        return profile;
      case 'profileEdit':
        return profileEdit;
      default:
        throw ArgumentError('Route name "$routeName" not found');
    }
  }

  /// Check if a route requires an ID parameter
  static bool requiresId(String routePath) {
    return routePath.contains(':id');
  }

  /// Build a route path with ID
  static String buildPathWithId(String basePath, String id) {
    return basePath.replaceFirst(':id', id);
  }
}

/// Named route constants for GoRouter
/// 
/// These names are used for programmatic navigation
/// and must match the route configuration in app/router.dart
class RouteNames {
  RouteNames._();

  static const String root = 'root';
  static const String shell = 'shell';
  static const String dashboard = 'dashboard';
  static const String orders = 'orders';
  static const String orderDetails = 'orderDetails';
  static const String products = 'products';
  static const String productCreate = 'productCreate';
  static const String productEdit = 'productEdit';
  static const String productDetails = 'productDetails';
  static const String categories = 'categories';
  static const String categoryCreate = 'categoryCreate';
  static const String categoryEdit = 'categoryEdit';
  static const String customers = 'customers';
  static const String customerDetails = 'customerDetails';
  static const String discounts = 'discounts';
  static const String discountCreate = 'discountCreate';
  static const String discountEdit = 'discountEdit';
  static const String reports = 'reports';
  static const String salesReport = 'salesReport';
  static const String inventoryReport = 'inventoryReport';
  static const String statistics = 'statistics';
  static const String notifications = 'notifications';
  static const String settings = 'settings';
  static const String settingsGeneral = 'settingsGeneral';
  static const String settingsSecurity = 'settingsSecurity';
  static const String settingsAppearance = 'settingsAppearance';
  static const String profile = 'profile';
  static const String profileEdit = 'profileEdit';
}