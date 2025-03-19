import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/core/routes/app_router.dart';
import 'package:spendeex/presentation/screens/home_screen.dart';
import 'package:spendeex/presentation/screens/login_screen.dart';
import 'package:spendeex/presentation/screens/main_screen.dart';
import 'package:spendeex/providers/auth_provider.dart';
import 'package:spendeex/providers/bottom_nav_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
         ChangeNotifierProvider(create: (_) => BottomNavProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Split Money',
            theme: ThemeData.dark(), // Dark Theme
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: '/',
            routes: {
          '/': (context) => Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return authProvider.isAuthenticated ? MainScreen() : LoginScreen();
                },
              ),
          '/login': (context) => LoginScreen(),
        },
          );
        },
      ),
    );
  }
}