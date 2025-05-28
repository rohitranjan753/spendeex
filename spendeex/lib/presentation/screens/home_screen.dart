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
      body:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            SizedBox(height: 16),
            _buildMonthlySpendingOverview(),
            SizedBox(height: 16),
            _buildActivityLogs(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement Add Expense Functionality
          // Open create group screen
          Navigator.pushNamed(context, '/create-group');
        },
        child: Icon(Icons.add),
      ),
    );
  }
  Widget _buildBalanceCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Balance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("\$5,000", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pending Payments", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text("\$500", style: TextStyle(fontSize: 18, color: Colors.red)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Receivables", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text("\$300", style: TextStyle(fontSize: 18, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySpendingOverview() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Monthly Spending Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 120, // Placeholder for graph/chart
              color: Colors.grey[800],
              child: Center(child: Text("Graph Placeholder", style: TextStyle(color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildActivityLogs() {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Recent Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    _buildActivityItem("Paid Rent", "-\$1000", Colors.red),
                    _buildActivityItem("Received from John", "+\$200", Colors.green),
                    _buildActivityItem("Dinner with Friends", "-\$50", Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String amount, Color color) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 14)),
      trailing: Text(amount, style: TextStyle(fontSize: 14, color: color)),
    );
  }
}
