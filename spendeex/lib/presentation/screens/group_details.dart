import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/config/theme.dart';
import 'package:spendeex/presentation/screens/add_expense_screen.dart';
import 'package:spendeex/presentation/widgets/shimmer_widgets.dart';
import 'package:spendeex/providers/group_details_provider.dart';
import 'package:intl/intl.dart';

class GroupDetails extends StatefulWidget {
  final String? groupName;
  final String? groupId;

  const GroupDetails({Key? key, this.groupName, this.groupId}) : super(key: key);

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load group details when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.groupId != null) {
        context.read<GroupDetailsProvider>().loadGroupDetails(widget.groupId!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupDetailsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppTheme.primaryBlack,
          appBar: AppBar(
            title: Text(widget.groupName ?? 'Group Details'),
            centerTitle: true,
            backgroundColor: AppTheme.primaryBlack,
            foregroundColor: AppTheme.primaryWhite,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => provider.refreshData(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryWhite,
              labelColor: AppTheme.primaryWhite,
              unselectedLabelColor: AppTheme.mediumGrey,
              tabs: [
                Tab(text: 'Expenses', icon: Icon(Icons.receipt)),
                Tab(text: 'Balances', icon: Icon(Icons.account_balance_wallet)),
                Tab(text: 'Activity', icon: Icon(Icons.history)),
              ],
            ),
          ),
          body:
              provider.isLoading
                  ? Column(
                      children: [
                      // Group summary shimmer
                      Container(
                        margin: EdgeInsets.all(16),
                        child: ShimmerWidgets.groupDetailsShimmer(),
                      ),
                      // Member filter shimmer
                      Container(
                        height: 60,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(right: 8),
                              child: ShimmerWidgets.textShimmer(
                                width: 80,
                                height: 32,
                              ),
                            );
                          },
                        ),
                      ),
                        SizedBox(height: 16),
                      // Content shimmer
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: ShimmerWidgets.listItemShimmer(
                                height: 100,
                              ),
                            );
                          },
                        ),
                        ),
                    ],
                  )
              : provider.error != null
                  ? _buildErrorWidget(provider)
                  : Column(
                      children: [
                        _buildGroupSummary(provider),
                        _buildMemberFilter(provider),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildExpensesTab(provider),
                              _buildBalancesTab(provider),
                              _buildActivityTab(provider),
                            ],
                          ),
                        ),
                      ],
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpenseScreen()),
              );
              if (result == true) {
                provider.refreshData();
              }
            },
            backgroundColor: AppTheme.primaryWhite,
            foregroundColor: AppTheme.primaryBlack,
            icon: Icon(Icons.add),
            label: Text('Add Expense'),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(GroupDetailsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          SizedBox(height: 16),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppTheme.primaryWhite),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.refreshData(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSummary(GroupDetailsProvider provider) {
    if (provider.group == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.surfaceBlack, AppTheme.cardBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkGrey),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total Spent',
                '₹${provider.getTotalExpenses().toStringAsFixed(2)}',
                Icons.money,
              ),
              _buildSummaryItem(
                'Members',
                '${provider.members.length}',
                Icons.people,
              ),
              _buildSummaryItem(
                'Expenses',
                '${provider.expenses.length}',
                Icons.receipt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryWhite, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.lightGrey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberFilter(GroupDetailsProvider provider) {
    if (provider.members.isEmpty) return SizedBox.shrink();

    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.members.length + 1, // +1 for "All" option
        itemBuilder: (context, index) {
          final isSelected = provider.selectedMemberIndex == index;
          final isAllOption = index == 0;
          
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) => provider.setSelectedMember(index),
              label: Text(
                isAllOption ? 'All' : provider.getMemberNameSync(provider.members[index - 1].userId),
                style: TextStyle(
                  color:
                      isSelected
                          ? AppTheme.primaryBlack
                          : AppTheme.primaryWhite,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: AppTheme.surfaceBlack,
              selectedColor: AppTheme.primaryWhite,
              checkmarkColor: AppTheme.primaryBlack,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryWhite : AppTheme.darkGrey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpensesTab(GroupDetailsProvider provider) {
    final expenses = provider.filteredExpenses;
    
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppTheme.mediumGrey),
            SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first expense to get started!',
              style: TextStyle(color: AppTheme.mediumGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: AppTheme.cardBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.surfaceBlack,
              child: Icon(Icons.receipt, color: AppTheme.primaryWhite),
            ),
            title: Text(
              expense.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  'Paid by: ${provider.getMemberNameSync(expense.paidBy)}',
                  style: TextStyle(color: AppTheme.lightGrey),
                ),
                Text(
                  'Category: ${expense.category}',
                  style: TextStyle(color: AppTheme.lightGrey),
                ),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(expense.date)}',
                  style: TextStyle(color: AppTheme.lightGrey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen,
                  ),
                ),
                if (expense.imageUrl != null)
                  Icon(Icons.image, size: 16, color: AppTheme.mediumGrey),
              ],
            ),
            onTap: () {
              // TODO: Navigate to expense details
            },
          ),
        );
      },
    );
  }

  Widget _buildBalancesTab(GroupDetailsProvider provider) {
    final filteredMembers = provider.filteredMembers;
    
    if (filteredMembers.isEmpty) {
      return Center(
        child: Text(
          'No members found',
          style: TextStyle(color: AppTheme.mediumGrey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredMembers.length,
      itemBuilder: (context, index) {
        final member = filteredMembers[index];
        final balance = provider.getUserBalance(member.userId);
        final isPositive = balance > 0;
        final isZero = balance == 0;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: AppTheme.cardBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isZero
                      ? AppTheme.surfaceBlack
                  : isPositive
                      ? AppTheme.successGreen.withOpacity(0.2)
                      : AppTheme.errorRed.withOpacity(0.2),
              child: Icon(
                isZero
                    ? Icons.check
                    : isPositive
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                color: isZero
                        ? AppTheme.mediumGrey
                    : isPositive
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
              ),
            ),
            title: Text(
              provider.getMemberNameSync(member.userId),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
            subtitle: Text(
              member.role.toUpperCase(),
              style: TextStyle(
                color:
                    member.role == 'admin'
                        ? AppTheme.warningOrange
                        : AppTheme.mediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isZero
                      ? 'Settled'
                      : isPositive
                          ? 'Gets back'
                          : 'Owes',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGrey,
                  ),
                ),
                Text(
                  isZero ? '' : '₹${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isZero
                            ? AppTheme.mediumGrey
                        : isPositive
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityTab(GroupDetailsProvider provider) {
    final filteredActivities = provider.filteredActivityLogs;
    
    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppTheme.mediumGrey),
            SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        final activity = filteredActivities[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          color: AppTheme.cardBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: AppTheme.surfaceBlack,
              child: Text(
                activity.actionIcon,
                style: TextStyle(fontSize: 20, color: AppTheme.primaryWhite),
              ),
            ),
            title: Text(
              activity.formattedAction,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  activity.details,
                  style: TextStyle(color: AppTheme.lightGrey),
                ),
                SizedBox(height: 4),
                Text(
                  'by ${provider.getMemberNameSync(activity.userId)}',
                  style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
                ),
              ],
            ),
            trailing: Text(
              _formatActivityDate(activity.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.mediumGrey,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatActivityDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
