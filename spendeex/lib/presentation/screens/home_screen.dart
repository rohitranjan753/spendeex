import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spendeex/config/theme.dart';
import 'package:spendeex/core/routes/app_routes.dart';
import 'package:spendeex/providers/home_provider.dart';
import 'package:spendeex/presentation/widgets/shimmer_widgets.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadDashboardData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.primaryBlack,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppTheme.primaryBlack,
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()}!',
                  style: TextStyle(fontSize: 16, color: AppTheme.mediumGrey),
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryWhite),
                ),
              ],
            ),
            // actions: [
            //   IconButton(
            //     icon: Container(
            //       padding: EdgeInsets.all(8),
            //       decoration: BoxDecoration(
            //         color: AppTheme.surfaceBlack,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Icon(Icons.refresh, color: AppTheme.primaryWhite),
            //     ),
            //     onPressed: () => provider.refresh(),
            //   ),
            //   SizedBox(width: 8),
            //   IconButton(
            //     icon: Container(
            //       padding: EdgeInsets.all(8),
            //       decoration: BoxDecoration(
            //         color: AppTheme.surfaceBlack,
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Icon(Icons.logout, color: AppTheme.primaryWhite),
            //     ),
            //     onPressed: () => _showLogoutDialog(context, authProvider),
            //   ),
            //   SizedBox(width: 16),
            // ],
          ),
          body: provider.isLoading
              ? _buildLoadingScreen()
              : provider.error != null
                  ? _buildErrorScreen(provider)
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: RefreshIndicator(
                        color: AppTheme.primaryWhite,
                        backgroundColor: AppTheme.surfaceBlack,
                        onRefresh: () => provider.loadDashboardData(),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBalanceCard(provider),
                              SizedBox(height: 20),
                              _buildQuickActions(),
                              SizedBox(height: 20),
                              _buildMonthlySpendingOverview(provider),
                              SizedBox(height: 20),
                              _buildInsightsSection(provider),
                              SizedBox(height: 20),
                              _buildActivityLogs(provider),
                              SizedBox(height: 100), // Extra space for FAB
                            ],
                          ),
                        ),
                      ),
                    ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card shimmer
          ShimmerWidgets.cardShimmer(height: 180),
          SizedBox(height: 20),

          // Quick actions shimmer
          ShimmerWidgets.textShimmer(width: 150, height: 20),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: ShimmerWidgets.cardShimmer(height: 100)),
              SizedBox(width: 12),
              Expanded(child: ShimmerWidgets.cardShimmer(height: 100)),
              SizedBox(width: 12),
              Expanded(child: ShimmerWidgets.cardShimmer(height: 100)),
            ],
          ),

          SizedBox(height: 20),

          // Monthly spending overview shimmer
          ShimmerWidgets.cardShimmer(height: 220),

          SizedBox(height: 20),

          // Insights shimmer
          ShimmerWidgets.cardShimmer(height: 160),

          SizedBox(height: 20),

          // Activity logs shimmer
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBlack,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.darkGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerWidgets.textShimmer(width: 120, height: 18),
                    ShimmerWidgets.textShimmer(width: 60, height: 16),
                  ],
                ),
                SizedBox(height: 16),
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: ShimmerWidgets.listItemShimmer(height: 60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(HomeProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryWhite),
          ),
          SizedBox(height: 8),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mediumGrey),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.refresh(),
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryWhite,
              foregroundColor: AppTheme.primaryBlack,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(HomeProvider provider) {
    final isPositiveBalance = provider.totalBalance >= 0;
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositiveBalance 
              ? [AppTheme.surfaceBlack, AppTheme.cardBlack]
              : [AppTheme.cardBlack, AppTheme.surfaceBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositiveBalance ? AppTheme.successGreen : AppTheme.errorRed,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Balance",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightGrey,
                ),
              ),
              Icon(
                isPositiveBalance ? Icons.trending_up : Icons.trending_down,
                color: isPositiveBalance ? AppTheme.successGreen : AppTheme.errorRed,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "₹${provider.totalBalance.abs().toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryWhite,
            ),
          ),
          if (!isPositiveBalance)
            Text(
              "You owe money",
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.lightGrey,
              ),
            ),
          SizedBox(height: 20),
          Container(
            height: 1,
            color: AppTheme.darkGrey,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  "Pending",
                  "₹${provider.pendingPayments.toStringAsFixed(0)}",
                  Icons.schedule,
                  AppTheme.warningOrange,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.darkGrey),
              Expanded(
                child: _buildBalanceItem(
                  "Receivables",
                  "₹${provider.receivables.toStringAsFixed(0)}",
                  Icons.account_balance_wallet,
                  AppTheme.primaryWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String title, String amount, IconData icon, Color iconColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightGrey,
            ),
          ),
          SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
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
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                "Add Expense",
                Icons.add_circle_outline,
                AppTheme.primaryWhite,
                () => Navigator.pushNamed(context, AppRoutes.addExpense),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "Create Group",
                Icons.group_add,
                AppTheme.primaryWhite,
                () => Navigator.pushNamed(context, AppRoutes.createGroup),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "View Stats",
                Icons.analytics,
                AppTheme.primaryWhite,
                () => Navigator.pushNamed(context, AppRoutes.stats),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.darkGrey),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
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

  Widget _buildMonthlySpendingOverview(HomeProvider provider) {
    final weeklyData = provider.getWeeklySpendingData();
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "This Month's Spending",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryWhite,
                ),
              ),
              Text(
                "₹${provider.monthlySpending.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: weeklyData.isNotEmpty
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < weeklyData.length) {
                                return Text(
                                  weeklyData[index]['dayName'],
                                  style: TextStyle(color: AppTheme.mediumGrey, fontSize: 12),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: weeklyData.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value['amount']);
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.primaryWhite,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppTheme.primaryWhite,
                                strokeWidth: 2,
                                strokeColor: AppTheme.cardBlack,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryWhite.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'No spending data available',
                      style: TextStyle(color: AppTheme.mediumGrey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(HomeProvider provider) {
    final categoryData = provider.getMonthlyCategoyBreakdown();
    final topCategories = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spending Insights",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryWhite,
            ),
          ),
          SizedBox(height: 16),
          if (topCategories.isNotEmpty) ...[
            ...topCategories.take(3).map((entry) => _buildCategoryInsight(
              entry.key,
              entry.value,
              categoryData.values.fold(0.0, (a, b) => a + b),
            )).toList(),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No spending data this month',
                  style: TextStyle(color: AppTheme.mediumGrey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryInsight(String category, double amount, double total) {
    final percentage = total > 0 ? (amount / total * 100).round() : 0;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.getCategoryColor(category),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: AppTheme.primaryWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(0)} ($percentage%)',
                      style: TextStyle(
                        color: AppTheme.lightGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: amount / total,
                  backgroundColor: AppTheme.darkGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getCategoryColor(category)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogs(HomeProvider provider) {
    final activities = provider.getFormattedActivities();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryWhite,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity log
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: AppTheme.primaryWhite),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (activities.isNotEmpty) ...[
            ...activities.map((activity) => _buildActivityItem(
              activity['title'],
              activity['subtitle'],
              activity['user'],
              activity['time'],
              activity['isExpense'] ?? false,
              activity['isPayment'] ?? false,
              activity['isGroup'] ?? false,
            )).toList(),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: AppTheme.mediumGrey),
                    SizedBox(height: 8),
                    Text(
                      'No recent activity',
                      style: TextStyle(color: AppTheme.mediumGrey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String user,
    DateTime time,
    bool isExpense,
    bool isPayment,
    bool isGroup,
  ) {
    IconData icon;
    Color iconColor;

    if (isExpense) {
      icon = Icons.receipt_long;
      iconColor = AppTheme.primaryWhite;
    } else if (isPayment) {
      icon = Icons.payment;
      iconColor = AppTheme.successGreen;
    } else if (isGroup) {
      icon = Icons.group;
      iconColor = AppTheme.lightGrey;
    } else {
      icon = Icons.info_outline;
      iconColor = AppTheme.mediumGrey;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBlack,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryWhite,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.mediumGrey,
                    ),
                  ),
                Text(
                  'by $user • ${_formatTime(time)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.lightGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.addExpense);
      },
      backgroundColor: AppTheme.primaryWhite,
      foregroundColor: AppTheme.primaryBlack,
      icon: Icon(Icons.add),
      label: Text("Add Expense"),
      elevation: 8,
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBlack,
          title: Text(
            'Logout',
            style: TextStyle(color: AppTheme.primaryWhite),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: AppTheme.lightGrey),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppTheme.mediumGrey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.signOut();
              },
            ),
          ],
        );
      },
    );
  }
}
