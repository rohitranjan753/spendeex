import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/config/theme.dart';
import 'package:spendeex/presentation/widgets/shimmer_widgets.dart';
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
            backgroundColor: AppTheme.primaryBlack,
            body: CustomScrollView(
              slivers: [
                // Shimmer AppBar
                SliverAppBar(
                  expandedHeight: 280,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: AppTheme.primaryBlack,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.surfaceBlack, AppTheme.cardBlack],
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            // Profile avatar shimmer
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryWhite, width: 4),
                              ),
                              child: ShimmerWidgets.circularShimmer(size: 100),
                            ),
                            SizedBox(height: 16),
                            // Name shimmer
                            ShimmerWidgets.textShimmer(width: 150, height: 28),
                            SizedBox(height: 8),
                            // Email shimmer
                            ShimmerWidgets.textShimmer(width: 200, height: 16),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats cards shimmer
                        Row(
                          children: [
                            Expanded(child: ShimmerWidgets.cardShimmer(height: 120)),
                            SizedBox(width: 16),
                            Expanded(child: ShimmerWidgets.cardShimmer(height: 120)),
                          ],
                        ),
                        SizedBox(height: 24),
                        // Quick actions shimmer
                        ShimmerWidgets.textShimmer(width: 120, height: 20),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: ShimmerWidgets.cardShimmer(height: 80)),
                            SizedBox(width: 12),
                            Expanded(child: ShimmerWidgets.cardShimmer(height: 80)),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: ShimmerWidgets.cardShimmer(height: 80)),
                            SizedBox(width: 12),
                            Expanded(child: ShimmerWidgets.cardShimmer(height: 80)),
                          ],
                        ),
                        SizedBox(height: 24),
                        // Recent activity shimmer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerWidgets.textShimmer(width: 130, height: 20),
                            ShimmerWidgets.textShimmer(width: 70, height: 16),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceBlack,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.darkGrey),
                          ),
                          child: Column(
                            children: List.generate(3, (index) => 
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: ShimmerWidgets.listItemShimmer(height: 60),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // Past expenses shimmer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerWidgets.textShimmer(width: 120, height: 20),
                            ShimmerWidgets.textShimmer(width: 70, height: 16),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceBlack,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.darkGrey),
                          ),
                          child: Column(
                            children: List.generate(
                              4,
                              (index) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: ShimmerWidgets.listItemShimmer(
                                  height: 60,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (profileProvider.error != null) {
          return Scaffold(
            backgroundColor: AppTheme.primaryBlack,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                  SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryWhite),
                  ),
                  SizedBox(height: 8),
                  Text(
                    profileProvider.error!,
                    style: TextStyle(color: AppTheme.mediumGrey),
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
          backgroundColor: AppTheme.primaryBlack,
          body: RefreshIndicator(
            color: AppTheme.primaryWhite,
            backgroundColor: AppTheme.surfaceBlack,
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
      backgroundColor: AppTheme.primaryBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.surfaceBlack, AppTheme.cardBlack],
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
                    color: AppTheme.primaryWhite,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  provider.userEmail,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.lightGrey,
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: AppTheme.primaryWhite),
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
        border: Border.all(color: AppTheme.primaryWhite, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlack.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppTheme.surfaceBlack,
        backgroundImage:
            provider.userProfilePic != null
                ? NetworkImage(provider.userProfilePic!)
                : null,
        child:
            provider.userProfilePic == null
                ? Icon(Icons.person, size: 50, color: AppTheme.primaryWhite)
                : null,
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
            color: AppTheme.errorRed,
            backgroundColor: AppTheme.surfaceBlack,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: "Money Owed",
            value: "₹${provider.moneyOwed.toStringAsFixed(0)}",
            icon: Icons.account_balance_wallet,
            color: AppTheme.warningOrange,
            backgroundColor: AppTheme.surfaceBlack,
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
        border: Border.all(color: AppTheme.darkGrey),
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
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryWhite,
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
            color: AppTheme.primaryWhite,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: "Add Expense",
                icon: Icons.add_circle_outline,
                color: AppTheme.successGreen,
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
                color: AppTheme.primaryWhite,
                onTap: () {
                  Navigator.pushNamed(context, '/add-expense');
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: "View Stats",
                icon: Icons.analytics_outlined,
                color: AppTheme.lightGrey,
                onTap: () {
                  Navigator.pushNamed(context, '/stats');
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: "Settings",
                icon: Icons.settings_outlined,
                color: AppTheme.mediumGrey,
                onTap: () {
                  // TODO: Navigate to settings
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
          color: AppTheme.surfaceBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkGrey),
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
                color: AppTheme.primaryWhite,
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
                color: AppTheme.primaryWhite,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all activities
              },
              child: Text("View All", style: TextStyle(color: AppTheme.primaryWhite)),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkGrey),
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
                            color: AppTheme.mediumGrey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.mediumGrey,
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
                                        ? AppTheme.primaryWhite
                                        : activity['isPayment']
                                        ? AppTheme.successGreen
                                        : AppTheme.lightGrey,
                                iconBg: AppTheme.cardBlack,
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
                    color: AppTheme.primaryWhite,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppTheme.mediumGrey),
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
                color: AppTheme.primaryWhite,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all expenses
              },
              child: Text("View All", style: TextStyle(color: AppTheme.primaryWhite)),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.darkGrey),
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
                            color: AppTheme.mediumGrey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recent expenses',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.mediumGrey,
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
                    color: AppTheme.primaryWhite,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  category,
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
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
                  color: settled ? AppTheme.successGreen : AppTheme.warningOrange,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: settled ? AppTheme.successGreen.withOpacity(0.2) : AppTheme.warningOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  settled ? "Settled" : "Pending",
                  style: TextStyle(
                    fontSize: 12,
                    color: settled ? AppTheme.successGreen : AppTheme.warningOrange,
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
          backgroundColor: AppTheme.errorRed.withOpacity(0.2),
          foregroundColor: AppTheme.errorRed,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          side: BorderSide(color: AppTheme.errorRed.withOpacity(0.5)),
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
          backgroundColor: AppTheme.cardBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Logout", style: TextStyle(color: AppTheme.primaryWhite)),
          content: Text("Are you sure you want to logout?", style: TextStyle(color: AppTheme.lightGrey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: AppTheme.mediumGrey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.primaryWhite,
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
                      backgroundColor: AppTheme.errorRed,
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
