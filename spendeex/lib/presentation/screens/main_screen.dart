import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/presentation/screens/group_screen.dart';
import 'package:spendeex/presentation/screens/home_screen.dart';
import 'package:spendeex/presentation/screens/profile_screen.dart';
import 'package:spendeex/presentation/screens/stats_screen.dart';
import 'package:spendeex/presentation/widgets/bottom_nav_bar.dart';
import 'package:spendeex/providers/bottom_nav_provider.dart';

class MainScreen extends StatelessWidget {
  final List<Widget> _screens = [
    HomeScreen(),
    GroupScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(
      builder: (context, bottomNavProvider, _) {
        return Scaffold(
          body: _screens[bottomNavProvider.selectedIndex], // Display the selected screen
          bottomNavigationBar: BottomNavBar(),
        );
      },
    );
  }
}
