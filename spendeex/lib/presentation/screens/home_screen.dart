import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/providers/bottom_nav_provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final bottomNavProvider = Provider.of<BottomNavProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => authProvider.signOut(),
          )
        ],
      ),
      body: Center(
        child: Text(
          "Welcome to Split Money!",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
