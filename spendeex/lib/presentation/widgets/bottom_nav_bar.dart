import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/config/theme.dart';
import 'package:spendeex/providers/bottom_nav_provider.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBlack,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGrey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            backgroundColor: AppTheme.primaryBlack,
            color: AppTheme.mediumGrey,
            activeColor: AppTheme.primaryWhite,
            tabBackgroundColor: AppTheme.surfaceBlack,
            gap: 8,
            padding: EdgeInsets.all(16),
            selectedIndex: bottomNavProvider.selectedIndex,
            onTabChange: (index) => bottomNavProvider.updateIndex(index),
            tabs: [
              GButton(icon: Icons.home, text: "Home"),
              GButton(icon: Icons.people, text: "Group"),
              GButton(icon: Icons.emoji_people, text: "FriendS"),
              GButton(icon: Icons.person, text: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}
