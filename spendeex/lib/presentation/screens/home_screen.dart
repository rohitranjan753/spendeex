import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:spendeex/core/routes/app_routes.dart';
import 'package:spendeex/providers/home_provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<HomeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()}!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.refresh, color: Colors.white),
                ),
                onPressed: () => provider.refresh(),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.logout, color: Colors.white),
                ),
                onPressed: () => _showLogoutDialog(context, authProvider),
              ),
              SizedBox(width: 16),
            ],
          ),
          body: provider.isLoading
              ? _buildLoadingScreen()
              : provider.error != null
                  ? _buildErrorScreen(provider)
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: RefreshIndicator(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Loading your dashboard...',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
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
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => provider.refresh(),
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
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
              ? [Colors.green[600]!, Colors.green[400]!]
              : [Colors.red[600]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPositiveBalance ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
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
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Icon(
                isPositiveBalance ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
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
              color: Colors.white,
            ),
          ),
          if (!isPositiveBalance)
            Text(
              "You owe money",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  "Pending",
                  "₹${provider.pendingPayments.toStringAsFixed(0)}",
                  Icons.schedule,
                  Colors.orange[300]!,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
              Expanded(
                child: _buildBalanceItem(
                  "Receivables",
                  "₹${provider.receivables.toStringAsFixed(0)}",
                  Icons.account_balance_wallet,
                  Colors.lightBlue[300]!,
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
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                "Add Expense",
                Icons.add_circle_outline,
                Colors.blue,
                () => Navigator.pushNamed(context, AppRoutes.addExpense),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "Create Group",
                Icons.group_add,
                Colors.purple,
                () => Navigator.pushNamed(context, AppRoutes.createGroup),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                "View Stats",
                Icons.analytics,
                Colors.green,
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
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                color: Colors.white,
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
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[700]!),
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
                  color: Colors.white,
                ),
              ),
              Text(
                "₹${provider.monthlySpending.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
                                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      'No spending data available',
                      style: TextStyle(color: Colors.grey[400]),
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
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spending Insights",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                  style: TextStyle(color: Colors.grey[400]),
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
              color: _getCategoryColor(category),
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
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(0)} ($percentage%)',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: amount / total,
                  backgroundColor: Colors.grey[600],
                  valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(category)),
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
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[700]!),
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
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full activity log
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: Colors.blue),
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
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[600]),
                    SizedBox(height: 8),
                    Text(
                      'No recent activity',
                      style: TextStyle(color: Colors.grey[400]),
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
      iconColor = Colors.blue;
    } else if (isPayment) {
      icon = Icons.payment;
      iconColor = Colors.green;
    } else if (isGroup) {
      icon = Icons.group;
      iconColor = Colors.purple;
    } else {
      icon = Icons.info_outline;
      iconColor = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
                    color: Colors.white,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                Text(
                  'by $user • ${_formatTime(time)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
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
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
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

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.red,
      Colors.purple, Colors.teal, Colors.indigo, Colors.amber,
    ];
    return colors[category.hashCode % colors.length];
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
          backgroundColor: Colors.grey[800],
          title: Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: Colors.red)),
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
