import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../core/widgets/main_layout.dart';
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

// Placeholder pages for routes not yet implemented
class _DummyPage extends StatelessWidget {
  final String title;
  const _DummyPage(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
        initialLocation: AppRoutes.dashboard,
        navigatorKey: _rootNavigatorKey,
        routes: [
          // Routes inside the Main Layout (Sidebar + Topbar)
          ShellRoute(
            builder: (context, state, child) => MainLayout(child: child),
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: AppRoutes.dashboard,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.orders,
                name: AppRoutes.orders,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _DummyPage('سفارشات'),
                ),
              ),
              GoRoute(
                path: AppRoutes.products,
                name: AppRoutes.products,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProductsListScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.customers,
                name: AppRoutes.customers,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _DummyPage('مشتریان'),
                ),
              ),
              GoRoute(
                path: AppRoutes.categories,
                name: AppRoutes.categories,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CategoriesListScreen(),
                ),
              ),
              GoRoute(
                path: '/banners',
                name: 'banners',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: BannersListScreen(),
                ),
              ),
              GoRoute(
                path: '/discounts', // Added Discounts List Route
                name: 'discounts',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DiscountsListScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.reports,
                name: AppRoutes.reports,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _DummyPage('گزارشات'),
                ),
              ),
              GoRoute(
                path: AppRoutes.settings,
                name: AppRoutes.settings,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _DummyPage('تنظیمات'),
                ),
              ),
            ],
          ),
          
          // --- Category Full Screen Routes ---
          GoRoute(
            path: '/categories/add',
            name: 'category_add',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: CategoryFormScreen(),
            ),
          ),
          GoRoute(
            path: '/categories/edit/:id',
            name: 'category_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final categoryId = int.parse(state.pathParameters['id']!);
              return MaterialPage(
                child: CategoryFormScreen(categoryId: categoryId),
              );
            },
          ),

          // --- Product Full Screen Routes ---
          GoRoute(
            path: '/products/add',
            name: 'product_add',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: ProductFormScreen(),
            ),
          ),
          GoRoute(
            path: '/products/edit/:id',
            name: 'product_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final productId = int.parse(state.pathParameters['id']!);
              return MaterialPage(
                child: ProductFormScreen(productId: productId),
              );
            },
          ),
          GoRoute(
            path: '/products/details/:id',
            name: 'product_details',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final productId = int.parse(state.pathParameters['id']!);
              return MaterialPage(
                child: ProductDetailsScreen(productId: productId),
              );
            },
          ),

          // --- Banner Full Screen Routes ---
          GoRoute(
            path: '/banners/add',
            name: 'banner_add',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: BannerFormScreen(),
            ),
          ),
          GoRoute(
            path: '/banners/edit/:id',
            name: 'banner_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final bannerId = int.parse(state.pathParameters['id']!);
              return MaterialPage(
                child: BannerFormScreen(bannerId: bannerId),
              );
            },
          ),

          // --- Discount Full Screen Routes ---
          GoRoute(
            path: '/discounts/add',
            name: 'discount_add',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: DiscountFormScreen(),
            ),
          ),
          GoRoute(
            path: '/discounts/edit/:id',
            name: 'discount_edit',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) {
              final discountId = int.parse(state.pathParameters['id']!);
              return MaterialPage(
                child: DiscountFormScreen(discountId: discountId),
              );
            },
          ),
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Text('Page not found (404)'),
          ),
        ),
      );
}