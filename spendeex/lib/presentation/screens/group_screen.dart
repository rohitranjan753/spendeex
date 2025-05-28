import 'package:flutter/material.dart';
import 'package:spendeex/presentation/screens/group_details_screen.dart';

class GroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groups"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Create Group Screen
            },
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildGroupItem(context, "Trip to Goa", "₹12,000 Spent", 4),
          _buildGroupItem(context, "Flatmates", "₹4,500 Spent", 3),
          _buildGroupItem(context, "Office Lunch", "₹2,800 Spent", 5),
        ],
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, String name, String spent, int members) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Members: $members"),
        trailing: Text(spent, style: TextStyle(color: Colors.green)),
        onTap: () {
          // Navigate to Group Details Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupDetailsScreen(groupName: name)),
          );
        },
      ),
    );
  }
}
