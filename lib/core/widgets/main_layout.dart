import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_sizes.dart';
import '../theme/app_breakpoints.dart';
import 'app_sidebar.dart';
import 'app_topbar.dart';
import '../../providers/navigation_provider.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  // متد کمکی برای تبدیل مسیر (Route) به عنوان فارسی برای تاپ‌بار
  String _getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'داشبورد';
      case '/orders':
        return 'سفارشات';
      case '/products':
        return 'محصولات';
      case '/customers':
        return 'مشتریان';
      case '/categories':
        return 'دسته‌بندی‌ها';
      case '/banners':
        return 'بنرها';
      case '/discounts':
        return 'تخفیف‌ها';
      case '/reports':
        return 'گزارش‌ها';
      case '/settings':
        return 'تنظیمات';
      case '/reservations':
        return 'رزروها';
      case '/tables':
        return 'میزها';
      default:
        return 'داشبورد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.laptop; // 1024px
    final navProvider = context.watch<NavigationProvider>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    // Directionality is now applied globally in app.dart
    return Scaffold(
      key: scaffoldKey,
      drawer: isDesktop
          ? null
          : Drawer(
              width: AppSizes.sidebarWidth,
              child: const AppSidebar(),
            ),
      body: Row(
        children: [
          // Permanent Sidebar for Desktop (Will appear on the Right due to RTL)
          if (isDesktop) const AppSidebar(),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                AppTopbar(
                  // استفاده از متد تبدیل مسیر به فارسی
                  title: _getPageTitle(navProvider.currentRoute),
                  onMenuTap: () {
                    if (!isDesktop) {
                      scaffoldKey.currentState?.openDrawer();
                    }
                  },
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}