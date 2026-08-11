import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../core/widgets/main_layout.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/categories/screens/categories_list_screen.dart';
import '../features/categories/screens/category_form_screen.dart';
import '../features/products/screens/products_list_screen.dart';
import '../features/products/screens/product_form_screen.dart';
import '../features/products/screens/product_details_screen.dart';
import '../features/banners/screens/banners_list_screen.dart';
import '../features/banners/screens/banner_form_screen.dart';
import '../features/discounts/screens/discounts_list_screen.dart';
import '../features/discounts/screens/discount_form_screen.dart';
import '../features/customers/screens/customers_list_screen.dart';
import '../features/customers/screens/customer_details_screen.dart';
import '../features/orders/screens/orders_list_screen.dart';
import '../features/orders/screens/order_details_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/reservations/screens/reservations_list_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
        initialLocation: AppRoutes.login, // Changed to Login
        navigatorKey: _rootNavigatorKey,
        routes: [
          // Login Route (Outside Shell)
          GoRoute(
            path: AppRoutes.login,
            name: AppRoutes.login,
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LoginScreen(),
            ),
          ),

          // Routes inside the Main Layout (Sidebar + Topbar)
          ShellRoute(
            builder: (context, state, child) => MainLayout(child: child),
            routes: [
              GoRoute(path: AppRoutes.dashboard, name: AppRoutes.dashboard, pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen())),
              GoRoute(path: AppRoutes.orders, name: AppRoutes.orders, pageBuilder: (context, state) => const NoTransitionPage(child: OrdersListScreen())),
              GoRoute(path: AppRoutes.products, name: AppRoutes.products, pageBuilder: (context, state) => const NoTransitionPage(child: ProductsListScreen())),
              GoRoute(path: AppRoutes.customers, name: AppRoutes.customers, pageBuilder: (context, state) => const NoTransitionPage(child: CustomersListScreen())),
              GoRoute(path: AppRoutes.categories, name: AppRoutes.categories, pageBuilder: (context, state) => const NoTransitionPage(child: CategoriesListScreen())),
              GoRoute(path: '/banners', name: 'banners', pageBuilder: (context, state) => const NoTransitionPage(child: BannersListScreen())),
              GoRoute(path: '/discounts', name: 'discounts', pageBuilder: (context, state) => const NoTransitionPage(child: DiscountsListScreen())),
              GoRoute(path: AppRoutes.reservations, name: AppRoutes.reservations, pageBuilder: (context, state) => const NoTransitionPage(child: ReservationsListScreen())),
              GoRoute(path: AppRoutes.reports, name: AppRoutes.reports, pageBuilder: (context, state) => const NoTransitionPage(child: ReportsScreen())),
              GoRoute(path: AppRoutes.settings, name: AppRoutes.settings, pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen())),
            ],
          ),
          
          // Full Screen Routes
          GoRoute(path: '/categories/add', name: 'category_add', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (context, state) => const MaterialPage(child: CategoryFormScreen())),
          GoRoute(
            path: '/categories/edit/:id',
            name: 'category_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final categoryId = state.pathParameters['id']!; 
              return MaterialPage(child: CategoryFormScreen(categoryId: categoryId));
            },
          ),

          GoRoute(path: '/products/add', name: 'product_add', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (context, state) => const MaterialPage(child: ProductFormScreen())),
          GoRoute(
            path: '/products/edit/:id',
            name: 'product_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final productId = state.pathParameters['id']!;
              return MaterialPage(child: ProductFormScreen(productId: productId));
            },
          ),
          GoRoute(
            path: '/products/details/:id',
            name: 'product_details',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final productId = int.parse(state.pathParameters['id']!);
              return MaterialPage(child: ProductDetailsScreen(productId: productId));
            },
          ),

          GoRoute(path: '/banners/add', name: 'banner_add', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (context, state) => const MaterialPage(child: BannerFormScreen())),
          GoRoute(
            path: '/banners/edit/:id',
            name: 'banner_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final bannerId = state.pathParameters['id']!;
              return MaterialPage(child: BannerFormScreen(bannerId: bannerId));
            },
          ),

          GoRoute(path: '/discounts/add', name: 'discount_add', parentNavigatorKey: _rootNavigatorKey, pageBuilder: (context, state) => const MaterialPage(child: DiscountFormScreen())),
          GoRoute(
            path: '/discounts/edit/:id',
            name: 'discount_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final discountId = state.pathParameters['id']!;
              return MaterialPage(child: DiscountFormScreen(discountId: discountId));
            },
          ),

          GoRoute(
            path: '/customers/details/:id',
            name: 'customer_details',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final customerId = int.parse(state.pathParameters['id']!);
              return MaterialPage(child: CustomerDetailsScreen(customerId: customerId));
            },
          ),
          GoRoute(
            path: '/orders/details/:id',
            name: 'order_details',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final orderId = state.pathParameters['id']!;
              return MaterialPage(child: OrderDetailsScreen(orderId: orderId));
            },
          ),
        ],
        errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Page not found (404)'))),
      );
}