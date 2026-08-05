import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../providers/theme_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/navigation_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
  ];
}