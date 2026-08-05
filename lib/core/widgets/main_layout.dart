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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.laptop; // 1024px
    final navProvider = context.watch<NavigationProvider>();
    final scaffoldKey = GlobalKey<ScaffoldState>();

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
          // Permanent Sidebar for Desktop
          if (isDesktop) const AppSidebar(),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                AppTopbar(
                  title: navProvider.currentRoute.replaceAll('/', '').isEmpty 
                      ? 'داشبورد' 
                      : navProvider.currentRoute.replaceAll('/', ''),
                  onMenuTap: () {
                    if (!isDesktop) {
                      scaffoldKey.currentState?.openDrawer();
                    }
                  },
                ),
                Expanded(
                  child: Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).scaffoldBackgroundColor
                        : Theme.of(context).scaffoldBackgroundColor,
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