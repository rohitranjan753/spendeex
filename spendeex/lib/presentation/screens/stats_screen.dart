import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendeex/providers/stats_provider.dart';

class StatsScreen extends StatefulWidget {
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadStatsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Statistics"),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => provider.refresh(),
              ),
              IconButton(
                icon: Icon(Icons.download),
                onPressed: () => _showExportOptions(context, provider),
              ),
            ],
          ),
          body:
              provider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? _buildErrorWidget(provider)
                  : RefreshIndicator(
                    onRefresh: () => provider.loadStatsData(),
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthSelector(provider),
                          SizedBox(height: 16),
                          _buildMonthlyBreakdown(provider),
                          SizedBox(height: 16),
                          _buildSpendingGraph(context, provider),
                          SizedBox(height: 16),
                          _buildCategoryFilter(provider),
                          SizedBox(height: 16),
                          _buildCategoryBreakdown(provider),
                          SizedBox(height: 16),
                          _buildInsights(provider),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildErrorWidget(StatsProvider provider) {
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
            onPressed: () => provider.refresh(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(StatsProvider provider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Month",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectMonth(context, provider),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'MMMM yyyy',
                            ).format(provider.selectedMonth),
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown(StatsProvider provider) {
    final totalSpending = provider.getTotalSpending();
    final pending = provider.getPendingPayments();
    final owed = provider.getOwedAmount();
    final settled = provider.getSettledAmount();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Monthly Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MMM yyyy').format(provider.selectedMonth),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Total Spending: ₹${totalSpending.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryBox(
                  "Pending",
                  "₹${pending.toStringAsFixed(0)}",
                  Colors.orange,
                ),
                _buildSummaryBox(
                  "Owed to You",
                  "₹${owed.toStringAsFixed(0)}",
                  Colors.green,
                ),
                _buildSummaryBox(
                  "Settled",
                  "₹${settled.toStringAsFixed(0)}",
                  Colors.blue,
                ),
              ],
            ),
            if (totalSpending > 0) ...[
              SizedBox(height: 12),
              _buildBalanceIndicator(pending, owed, settled),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String title, String amount, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator(double pending, double owed, double settled) {
    final total = pending + owed + settled;
    if (total <= 0) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Balance Overview",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: Row(
            children: [
              if (pending > 0)
                Expanded(
                  flex: (pending * 100 / total).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              if (owed > 0)
                Expanded(
                  flex: (owed * 100 / total).round(),
                  child: Container(color: Colors.green),
                ),
              if (settled > 0)
                Expanded(
                  flex: (settled * 100 / total).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingGraph(BuildContext context, StatsProvider provider) {
    final graphData = provider.getSpendingGraphData();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Spending Pattern (Last 6 Months)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (provider.selectedCategory != 'All')
              Text(
                "Category: ${provider.selectedCategory}",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3,
              child:
                  graphData.isNotEmpty
                      ? LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: _calculateInterval(graphData),
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey[300]!,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  final month = graphData.firstWhere(
                                    (data) => data['month'] == value,
                                    orElse: () => {'monthName': ''},
                                  );
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      month['monthName'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: _calculateInterval(graphData),
                                reservedSize: 60,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  return Text(
                                    '₹${_formatAmount(value)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          minX:
                              graphData.isNotEmpty
                                  ? graphData.first['month'].toDouble()
                                  : 0,
                          maxX:
                              graphData.isNotEmpty
                                  ? graphData.last['month'].toDouble()
                                  : 12,
                          minY: 0,
                          maxY:
                              graphData.isNotEmpty
                                  ? graphData
                                          .map((e) => e['amount'] as double)
                                          .reduce((a, b) => a > b ? a : b) *
                                      1.1
                                  : 1000,
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  graphData
                                      .map(
                                        (data) => FlSpot(
                                          data['month'].toDouble(),
                                          data['amount'].toDouble(),
                                        ),
                                      )
                                      .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              isStrokeCapRound: true,
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
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor:
                                  (touchedSpot) => Colors.blueAccent,
                              getTooltipItems: (
                                List<LineBarSpot> touchedBarSpots,
                              ) {
                                return touchedBarSpots.map((barSpot) {
                                  final monthData = graphData.firstWhere(
                                    (data) => data['month'] == barSpot.x,
                                  );
                                  return LineTooltipItem(
                                    '${monthData['monthName']}\n₹${barSpot.y.toStringAsFixed(0)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      )
                      : Center(
                        child: Text(
                          'No spending data available',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(StatsProvider provider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter by Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              value: provider.selectedCategory,
              items:
                  provider.availableCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.setSelectedCategory(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(StatsProvider provider) {
    final categoryData = provider.getCategoryBreakdown();

    if (categoryData.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Category Breakdown",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...categoryData.entries
                .where((entry) => entry.value > 0)
                .map(
                  (entry) => _buildCategoryItem(
                    entry.key,
                    entry.value,
                    categoryData.values.fold(0.0, (a, b) => a + b),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount, double total) {
    final percentage = (amount / total * 100).round();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '₹${amount.toStringAsFixed(0)} ($percentage%)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: amount / total,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCategoryColor(category),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(StatsProvider provider) {
    final totalSpending = provider.getTotalSpending();
    final pending = provider.getPendingPayments();
    final owed = provider.getOwedAmount();

    if (totalSpending <= 0) return SizedBox.shrink();

    final netBalance = owed - pending;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Insights",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildInsightItem(
              Icons.account_balance_wallet,
              "Net Balance",
              netBalance >= 0
                  ? "You're owed ₹${netBalance.toStringAsFixed(0)}"
                  : "You owe ₹${(-netBalance).toStringAsFixed(0)}",
              netBalance >= 0 ? Colors.green : Colors.red,
            ),
            _buildInsightItem(
              Icons.trending_up,
              "Monthly Spending",
              "₹${totalSpending.toStringAsFixed(0)} this month",
              Colors.blue,
            ),
            if (pending > 0)
              _buildInsightItem(
                Icons.schedule,
                "Pending Payments",
                "₹${pending.toStringAsFixed(0)} to settle",
                Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateInterval(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 1000;

    final maxAmount = data
        .map((e) => e['amount'] as double)
        .reduce((a, b) => a > b ? a : b);

    if (maxAmount <= 1000) return 200;
    if (maxAmount <= 5000) return 1000;
    if (maxAmount <= 10000) return 2000;
    return 5000;
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[category.hashCode % colors.length];
  }

  Future<void> _selectMonth(
    BuildContext context,
    StatsProvider provider,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.setSelectedMonth(picked);
    }
  }

  void _showExportOptions(BuildContext context, StatsProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.table_chart, color: Colors.green),
                title: Text('Export as CSV'),
                subtitle: Text('Download expense data as spreadsheet'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsCSV(provider);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Export as PDF'),
                subtitle: Text('Generate detailed report'),
                onTap: () {
                  Navigator.pop(context);
                  _exportAsPDF(provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportAsCSV(StatsProvider provider) {
    // TODO: Implement CSV export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV export functionality coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _exportAsPDF(StatsProvider provider) {
    // TODO: Implement PDF export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF export functionality coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
