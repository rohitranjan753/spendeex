import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/core/routes/app_router.dart';
import 'package:spendeex/presentation/screens/login_screen.dart';
import 'package:spendeex/presentation/screens/main_screen.dart';
import 'package:spendeex/providers/add_expense_provider.dart';
import 'package:spendeex/providers/auth_provider.dart';
import 'package:spendeex/providers/bottom_nav_provider.dart';
import 'package:spendeex/providers/create_group_provider.dart';
import 'package:spendeex/providers/group_provider.dart';
import 'package:spendeex/providers/group_details_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_)=> CreateGroupProvider()),
        ChangeNotifierProvider(create: (_) => AddExpenseProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => GroupDetailsProvider()),
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
              '/':
                  (context) => Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return authProvider.isAuthenticated
                          ? MainScreen()
                          : LoginScreen();
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
