import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../features/auth/screens/login_screen.dart';
// TODO: Import other screens (Dashboard, Orders, etc.) when created

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
        initialLocation: AppRoutes.login,
        navigatorKey: _rootNavigatorKey,
        routes: [
          GoRoute(
            path: AppRoutes.login,
            name: AppRoutes.login,
            builder: (context, state) => const LoginScreen(),
          ),
          // TODO: Add ShellRoute for Dashboard layout (Sidebar + Topbar) later
          // Example:
          // GoRoute(
          //   path: AppRoutes.dashboard,
          //   name: AppRoutes.dashboard,
          //   builder: (context, state) => const DashboardScreen(),
          // ),
        ],
        errorBuilder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Page not found (404)'),
          ),
        ),
      );
}