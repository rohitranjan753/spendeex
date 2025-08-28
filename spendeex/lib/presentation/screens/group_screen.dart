import 'package:flutter/material.dart';
import 'package:spendeex/core/routes/app_routes.dart';
import 'package:spendeex/presentation/screens/create_group_screen.dart';
import 'package:spendeex/presentation/screens/group_details.dart';
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 131, 42, 42),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text("Group $index"),
              subtitle: Text("₹${(index + 1) * 1000} Spent"),
              trailing: Text("${(index + 1) * 2} Members"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GroupDetails(groupName: "Group $index"),
                  ),
                );
              },
            ),
          );
        },
      ),
      // body: ListView(
      //   padding: EdgeInsets.all(16),
      //   children: [
      //     _buildGroupItem(context, "Trip to Goa", "₹12,000 Spent", 4),
      //     _buildGroupItem(context, "Flatmates", "₹4,500 Spent", 3),
      //     _buildGroupItem(context, "Office Lunch", "₹2,800 Spent", 5),
      //   ],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createGroup);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupItem(
    BuildContext context,
    String name,
    String spent,
    int members,
  ) {
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
            MaterialPageRoute(
              builder: (context) => GroupDetailsScreen(groupName: name),
            ),
          );
        },
      ),
    );
  }
}
