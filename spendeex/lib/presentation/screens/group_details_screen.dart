import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatelessWidget {
  final String groupName;

  GroupDetailsScreen({required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // TODO: Implement CSV/PDF Download
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(),
            SizedBox(height: 16),
            _buildGraph(),
            SizedBox(height: 16),
            _buildExpenseList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add Expense Flow
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Spent: ₹12,000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Members Owe:", style: TextStyle(fontSize: 16)),
            Text("John: ₹3,000\nAlice: ₹2,500\nMark: ₹1,500", style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildGraph() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Spending Distribution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 40, title: "John", color: Colors.blue),
                    PieChartSectionData(value: 30, title: "Alice", color: Colors.green),
                    PieChartSectionData(value: 20, title: "Mark", color: Colors.orange),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseList() {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Expenses", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    _buildExpenseItem("Dinner", "₹3,000", "John"),
                    _buildExpenseItem("Hotel", "₹6,000", "Alice"),
                    _buildExpenseItem("Transport", "₹3,000", "Mark"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseItem(String title, String amount, String paidBy) {
    return ListTile(
      title: Text(title),
      subtitle: Text("Paid by $paidBy"),
      trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
