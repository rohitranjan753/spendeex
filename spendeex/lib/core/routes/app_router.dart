import 'package:flutter/material.dart';
import 'package:spendeex/presentation/screens/create_group_screen.dart';
import 'package:spendeex/presentation/screens/home_screen.dart';
import 'package:spendeex/presentation/screens/login_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case AppRoutes.createGroup:
        return MaterialPageRoute(builder: (_) => CreateGroupScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
