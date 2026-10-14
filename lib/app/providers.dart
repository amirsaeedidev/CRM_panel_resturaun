import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/theme_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/restaurant_analytics_provider.dart'; // Added RestaurantAnalyticsProvider

import '../providers/products_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/banners_provider.dart';
import '../providers/discounts_provider.dart';
import '../providers/reservations_provider.dart';
import '../providers/tables_provider.dart';
import '../providers/reports_provider.dart';

import '../repositories/auth_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/products_repository.dart';
import '../repositories/categories_repository.dart';
import '../repositories/orders_repository.dart';
import '../repositories/banners_repository.dart';
import '../repositories/discounts_repository.dart';
import '../repositories/reservations_repository.dart';
import '../repositories/tables_repository.dart';
import '../repositories/reports_repository.dart';

import '../core/services/supabase_service.dart'; // Added to provide SupabaseClient

class AppProviders {
  static List<SingleChildWidget> get providers => [
    // Core Providers
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),

    // Repositories
    Provider<AuthRepository>(create: (_) => AuthRepository()),
    Provider<DashboardRepository>(create: (_) => DashboardRepository()),
    Provider<ProductsRepository>(create: (_) => ProductsRepository()),
    Provider<CategoriesRepository>(create: (_) => CategoriesRepository()),
    Provider<OrdersRepository>(create: (_) => OrdersRepository()),
    Provider<BannersRepository>(create: (_) => BannersRepository()),
    Provider<DiscountsRepository>(create: (_) => DiscountsRepository()),
    Provider<ReservationsRepository>(create: (_) => ReservationsRepository()),
    Provider<TablesRepository>(create: (_) => TablesRepository()),
    Provider<ReportsRepository>(create: (_) => ReportsRepository()),

    // Feature Providers
    ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(context.read<AuthRepository>()),
    ),
    ChangeNotifierProvider<DashboardProvider>(
      create: (context) => DashboardProvider(context.read<DashboardRepository>()),
    ),
    // Added RestaurantAnalyticsProvider with SupabaseClient injection
    ChangeNotifierProvider<RestaurantAnalyticsProvider>(
      create: (context) => RestaurantAnalyticsProvider(supabase: SupabaseService.client),
    ),
    ChangeNotifierProvider<ProductsProvider>(
      create: (context) => ProductsProvider(context.read<ProductsRepository>()),
    ),
    ChangeNotifierProvider<CategoriesProvider>(
      create: (context) => CategoriesProvider(context.read<CategoriesRepository>()),
    ),
    ChangeNotifierProvider<OrdersProvider>(
      create: (context) => OrdersProvider(context.read<OrdersRepository>()),
    ),
    ChangeNotifierProvider<BannersProvider>(
      create: (context) => BannersProvider(context.read<BannersRepository>()),
    ),
    ChangeNotifierProvider<DiscountsProvider>(
      create: (context) => DiscountsProvider(context.read<DiscountsRepository>()),
    ),
    ChangeNotifierProvider<ReservationsProvider>(
      create: (context) => ReservationsProvider(context.read<ReservationsRepository>()),
    ),
    ChangeNotifierProvider<TablesProvider>(
      create: (context) => TablesProvider(context.read<TablesRepository>()),
    ),
    ChangeNotifierProvider<ReportsProvider>(
      create: (context) => ReportsProvider(context.read<ReportsRepository>()),
    ),
  ];
}