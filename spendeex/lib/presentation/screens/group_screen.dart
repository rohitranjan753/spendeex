import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/core/routes/app_routes.dart';
import 'package:spendeex/presentation/screens/create_group_screen.dart';
import 'package:spendeex/presentation/screens/group_details.dart';
import 'package:spendeex/providers/group_provider.dart';
import 'package:spendeex/data/models/group_model.dart';

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  void initState() {
    super.initState();
    // Load groups when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadUserGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groups"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateGroupScreen()),
              );
              // Refresh groups if a new group was created
              if (result == true) {
                context.read<GroupProvider>().refreshGroups();
              }
            },
          ),
        ],
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading your groups..."),
                ],
              ),
            );
          }

          if (groupProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    groupProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => groupProvider.refreshGroups(),
                    child: Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (!groupProvider.hasGroups) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Groups Yet",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Create your first group to start\nsplitting expenses with friends!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateGroupScreen(),
                        ),
                      );
                      if (result == true) {
                        groupProvider.refreshGroups();
                      }
                    },
                    icon: Icon(Icons.add),
                    label: Text("Create Group"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => groupProvider.refreshGroups(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: groupProvider.userGroups.length,
              itemBuilder: (context, index) {
                final group = groupProvider.userGroups[index];
                return _buildGroupCard(context, group);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.createGroup,
          );
          if (result == true) {
            context.read<GroupProvider>().refreshGroups();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, GroupModel group) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getCategoryColor(group.category).withOpacity(0.8),
              _getCategoryColor(group.category).withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              _getCategoryEmoji(group.category),
              style: TextStyle(fontSize: 20),
            ),
          ),
          title: Text(
            group.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (group.description.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  group.description,
                  style: TextStyle(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.white70),
                  SizedBox(width: 4),
                  Text(
                    "${group.participants.length} members",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(group.createdAt),
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetails(
                  groupName: group.title,
                  groupId: group.id,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trip':
        return Colors.blue;
      case 'family':
        return Colors.green;
      case 'couple':
        return Colors.pink;
      case 'event':
        return Colors.purple;
      case 'project':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'trip':
        return '✈️';
      case 'family':
        return '👨‍👩‍👧‍👦';
      case 'couple':
        return '👫';
      case 'event':
        return '🎂';
      case 'project':
        return '🏢';
      default:
        return '🍀';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else if (difference < 30) {
      return '${(difference / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
