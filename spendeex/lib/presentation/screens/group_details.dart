import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/presentation/screens/add_expense_screen.dart';
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
          appBar: AppBar(
            title: Text(widget.groupName ?? 'Group Details'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => provider.refreshData(),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Expenses', icon: Icon(Icons.receipt)),
                Tab(text: 'Balances', icon: Icon(Icons.account_balance_wallet)),
                Tab(text: 'Activity', icon: Icon(Icons.history)),
              ],
            ),
          ),
          body: provider.isLoading
              ? Center(child: CircularProgressIndicator())
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
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
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
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
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
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
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
                isAllOption ? 'All' : provider.getMemberName(provider.members[index - 1].userId),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.blue,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
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
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first expense to get started!',
              style: TextStyle(color: Colors.grey[600]),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.receipt, color: Colors.green.shade700),
            ),
            title: Text(
              expense.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Paid by: ${provider.getMemberName(expense.paidBy)}'),
                Text('Category: ${expense.category}'),
                Text('Date: ${DateFormat('MMM dd, yyyy').format(expense.date)}'),
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
                    color: Colors.green,
                  ),
                ),
                if (expense.imageUrl != null)
                  Icon(Icons.image, size: 16, color: Colors.grey),
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
    if (provider.members.isEmpty) {
      return Center(child: Text('No members found'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.members.length,
      itemBuilder: (context, index) {
        final member = provider.members[index];
        final balance = provider.getUserBalance(member.userId);
        final isPositive = balance > 0;
        final isZero = balance == 0;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isZero
                  ? Colors.grey.shade200
                  : isPositive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
              child: Icon(
                isZero
                    ? Icons.check
                    : isPositive
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                color: isZero
                    ? Colors.grey.shade600
                    : isPositive
                        ? Colors.green.shade700
                        : Colors.red.shade700,
              ),
            ),
            title: Text(
              provider.getMemberName(member.userId),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              member.role.toUpperCase(),
              style: TextStyle(
                color: member.role == 'admin' ? Colors.orange : Colors.grey,
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
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  isZero ? '' : '₹${balance.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isZero
                        ? Colors.grey
                        : isPositive
                            ? Colors.green
                            : Colors.red,
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
    if (provider.activityLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.activityLogs.length,
      itemBuilder: (context, index) {
        final activity = provider.activityLogs[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                activity.actionIcon,
                style: TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              activity.formattedAction,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(activity.details),
                SizedBox(height: 4),
                Text(
                  'by ${provider.getMemberName(activity.userId)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Text(
              _formatActivityDate(activity.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
