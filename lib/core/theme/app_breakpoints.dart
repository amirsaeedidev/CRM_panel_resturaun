import 'package:flutter/widgets.dart';

class AppBreakpoints {
  AppBreakpoints._();

  // Breakpoint thresholds
  static const double smallMobile = 320;
  static const double mobile = 480;
  static const double tablet = 768;
  static const double laptop = 1024;
  static const double desktop = 1440;

  // Helper methods for direct size checks
  static bool isSmallMobile(double width) => width < mobile;
  static bool isMobile(double width) => width >= mobile && width < tablet;
  static bool isTablet(double width) => width >= tablet && width < laptop;
  static bool isLaptop(double width) => width >= laptop && width < desktop;
  static bool isDesktop(double width) => width >= desktop;

  // Context-aware helper methods
  static bool isSmallMobileContext(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isMobileContext(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobile &&
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTabletContext(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet &&
      MediaQuery.sizeOf(context).width < laptop;

  static bool isLaptopContext(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= laptop &&
      MediaQuery.sizeOf(context).width < desktop;

  static bool isDesktopContext(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}