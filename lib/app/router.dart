import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../core/widgets/main_layout.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/categories/screens/categories_list_screen.dart';
import '../features/categories/screens/category_form_screen.dart';

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
                  child: _DummyPage('محصولات'),
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
          
          // Routes OUTSIDE the Main Layout (Full Screen pages like Forms)
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
        ],
        errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Text('Page not found (404)'),
          ),
        ),
      );
}