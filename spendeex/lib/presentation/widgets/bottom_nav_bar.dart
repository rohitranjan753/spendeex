import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/providers/bottom_nav_provider.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade900, blurRadius: 5),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.grey.shade800,
          gap: 8,
          padding: EdgeInsets.all(16),
          selectedIndex: bottomNavProvider.selectedIndex,
          onTabChange: (index) => bottomNavProvider.updateIndex(index),
          tabs: [
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.people, text: "Group"),
            GButton(icon: Icons.graphic_eq, text: "Stats"),
            GButton(icon: Icons.person, text: "Profile"),
          ],
        ),
      ),
    );
  }
}
