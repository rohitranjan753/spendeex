import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/providers/profile_provider.dart';
import 'package:spendeex/data/repositories/auth_repository.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        if (profileProvider.error != null) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    profileProvider.error!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => profileProvider.refreshProfile(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: RefreshIndicator(
            onRefresh: () => profileProvider.refreshProfile(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, profileProvider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCards(profileProvider),
                        SizedBox(height: 24),
                        _buildQuickActions(context),
                        SizedBox(height: 24),
                        _buildActivitySection(profileProvider),
                        SizedBox(height: 24),
                        _buildPastExpensesSection(profileProvider),
                        SizedBox(height: 32),
                        _buildLogoutButton(context),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ProfileProvider provider) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue[600]!, Colors.purple[600]!],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                _buildProfileAvatar(provider),
                SizedBox(height: 16),
                Text(
                  provider.userName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  provider.userEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 12),
                _buildMembershipBadge(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to settings screen
          },
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(ProfileProvider provider) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage:
            provider.userProfilePic != null
                ? NetworkImage(provider.userProfilePic!)
                : null,
        child:
            provider.userProfilePic == null
                ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                : null,
      ),
    );
  }

  Widget _buildMembershipBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: 18),
          SizedBox(width: 6),
          Text(
            "Premium Member",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ProfileProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "Total Spent",
            value: "₹${provider.totalSpent.toStringAsFixed(0)}",
            icon: Icons.trending_down,
            color: Colors.red[400]!,
            backgroundColor: Colors.red[50]!,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: "Money Owed",
            value: "₹${provider.moneyOwed.toStringAsFixed(0)}",
            icon: Icons.account_balance_wallet,
            color: Colors.orange[400]!,
            backgroundColor: Colors.orange[50]!,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: "Add Expense",
                icon: Icons.add_circle_outline,
                color: Colors.green[600]!,
                onTap: () {
                  Navigator.pushNamed(context, '/add-expense');
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: "Split Bill",
                icon: Icons.call_split,
                color: Colors.blue[600]!,
                onTap: () {
                  Navigator.pushNamed(context, '/add-expense');
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: "View Stats",
                icon: Icons.analytics_outlined,
                color: Colors.purple[600]!,
                onTap: () {
                  Navigator.pushNamed(context, '/stats');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(ProfileProvider provider) {
    final activities = provider.getFormattedActivities();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all activities
              },
              child: Text("View All"),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child:
              activities.isEmpty
                  ? Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children:
                        activities.asMap().entries.map((entry) {
                          final index = entry.key;
                          final activity = entry.value;
                          return Column(
                            children: [
                              _buildActivityItem(
                                title: activity['title'],
                                subtitle: activity['subtitle'],
                                icon:
                                    activity['isExpense']
                                        ? Icons.receipt_long
                                        : activity['isPayment']
                                        ? Icons.payment
                                        : Icons.notifications,
                                iconColor:
                                    activity['isExpense']
                                        ? Colors.blue[400]!
                                        : activity['isPayment']
                                        ? Colors.green[400]!
                                        : Colors.purple[400]!,
                                iconBg:
                                    activity['isExpense']
                                        ? Colors.blue[50]!
                                        : activity['isPayment']
                                        ? Colors.green[50]!
                                        : Colors.purple[50]!,
                                isLast: index == activities.length - 1,
                              ),
                              if (index < activities.length - 1)
                                Divider(height: 1, indent: 70),
                            ],
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildPastExpensesSection(ProfileProvider provider) {
    final expenses = provider.getFormattedPastExpenses();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Past Expenses",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all expenses
              },
              child: Text("View All"),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child:
              expenses.isEmpty
                  ? Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recent expenses',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Column(
                    children:
                        expenses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final expense = entry.value;
                          return Column(
                            children: [
                              _buildExpenseItem(
                                title: expense['title'],
                                amount: expense['amount'],
                                settled: expense['settled'],
                                category: expense['category'],
                                isLast: index == expenses.length - 1,
                              ),
                              if (index < expenses.length - 1)
                                Divider(height: 1, indent: 16, endIndent: 16),
                            ],
                          );
                        }).toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem({
    required String title,
    required String amount,
    required bool settled,
    required String category,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: settled ? Colors.green[600] : Colors.orange[600],
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: settled ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  settled ? "Settled" : "Pending",
                  style: TextStyle(
                    fontSize: 12,
                    color: settled ? Colors.green[600] : Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[600],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          side: BorderSide(color: Colors.red[200]!),
        ),
        icon: Icon(Icons.logout_outlined),
        label: Text(
          "Logout",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          _showLogoutDialog(context);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await AuthRepository().signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to logout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
