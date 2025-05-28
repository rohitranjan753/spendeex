import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // TODO: Implement CSV/PDF Export
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthlyBreakdown(),
            SizedBox(height: 16),
            _buildSpendingGraph(context),
            SizedBox(height: 16),
            _buildCategoryFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Monthly Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Total Spending: ₹18,000", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryBox("Pending", "₹5,000", Colors.orange),
                _buildSummaryBox("Owed", "₹3,500", Colors.green),
                _buildSummaryBox("Settled", "₹9,500", Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String title, String amount, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: Text(amount, style: TextStyle(fontSize: 14, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSpendingGraph(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Spending Pattern", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(1, 2000),
                        FlSpot(2, 3500),
                        FlSpot(3, 1800),
                        FlSpot(4, 5000),
                        FlSpot(5, 3000),
                        FlSpot(6, 2500),
                      ],
                      isCurved: true,
                      // colors: [Colors.blue],
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category Breakdown", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              value: "Food",
              items: ["Food", "Travel", "Shopping", "Bills", "Others"]
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) {
                // TODO: Implement category filter logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
