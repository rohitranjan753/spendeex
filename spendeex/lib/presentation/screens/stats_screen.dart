import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendeex/config/theme.dart';
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
          backgroundColor: AppTheme.primaryBlack,
          appBar: AppBar(
            title: Text("Statistics"),
            backgroundColor: AppTheme.primaryBlack,
            foregroundColor: AppTheme.primaryWhite,
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
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primaryWhite),
                        SizedBox(height: 16),
                        Text(
                          "Loading statistics...",
                          style: TextStyle(color: AppTheme.mediumGrey),
                        ),
                      ],
                    ),
                  )
                  : provider.error != null
                  ? _buildErrorWidget(provider)
                  : RefreshIndicator(
                    color: AppTheme.primaryWhite,
                    backgroundColor: AppTheme.surfaceBlack,
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
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          SizedBox(height: 16),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppTheme.primaryWhite),
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
      color: AppTheme.cardBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Month",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
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
                        border: Border.all(color: AppTheme.darkGrey),
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.surfaceBlack,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'MMMM yyyy',
                            ).format(provider.selectedMonth),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.primaryWhite,
                            ),
                          ),
                          Icon(Icons.calendar_today, color: AppTheme.primaryWhite),
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
      color: AppTheme.cardBlack,
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
                  "Monthly Overview",
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryWhite,
                  ),
                ),
                Text(
                  DateFormat('MMM yyyy').format(provider.selectedMonth),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryBox("Total", "₹${totalSpending.toStringAsFixed(0)}", AppTheme.primaryWhite),
                _buildSummaryBox("Pending", "₹${pending.toStringAsFixed(0)}", AppTheme.warningOrange),
                _buildSummaryBox("Owed", "₹${owed.toStringAsFixed(0)}", AppTheme.errorRed),
                _buildSummaryBox("Settled", "₹${settled.toStringAsFixed(0)}", AppTheme.successGreen),
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
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                color: AppTheme.lightGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.5)),
              ),
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
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
    if (total == 0) return SizedBox.shrink();

    return Column(
      children: [
        Text(
          "Payment Status",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.lightGrey,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              if (pending > 0)
                Expanded(
                  flex: (pending * 100 / total).round(),
                  child: Container(color: AppTheme.warningOrange),
                ),
              if (owed > 0)
                Expanded(
                  flex: (owed * 100 / total).round(),
                  child: Container(color: AppTheme.errorRed),
                ),
              if (settled > 0)
                Expanded(
                  flex: (settled * 100 / total).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
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
      color: AppTheme.cardBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Spending Pattern (Last 6 Months)",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
            if (provider.selectedCategory != 'All')
              Text(
                "Category: ${provider.selectedCategory}",
                style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
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
                                color: AppTheme.darkGrey,
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
                                  final monthData = graphData.firstWhere(
                                    (data) => data['month'] == value,
                                    orElse: () => {'monthName': ''},
                                  );
                                  return Text(
                                    monthData['monthName']?.substring(0, 3) ?? '',
                                    style: TextStyle(
                                      color: AppTheme.mediumGrey,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '₹${(value / 1000).toStringAsFixed(0)}k',
                                    style: TextStyle(
                                      color: AppTheme.mediumGrey,
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
                              color: AppTheme.darkGrey,
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
                              color: AppTheme.primaryWhite,
                              barWidth: 3,
                              isStrokeCapRound: true,
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
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor:
                                  (touchedSpot) => AppTheme.cardBlack,
                              getTooltipItems: (
                                List<LineBarSpot> touchedBarSpots,
                              ) {
                                return touchedBarSpots.map((barSpot) {
                                  final monthData = graphData.firstWhere(
                                    (data) => data['month'] == barSpot.x,
                                  );
                                  return LineTooltipItem(
                                    '${monthData['monthName']}\n₹${barSpot.y.toStringAsFixed(0)}',
                                    TextStyle(
                                      color: AppTheme.primaryWhite,
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
                          style: TextStyle(color: AppTheme.mediumGrey),
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
      color: AppTheme.cardBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter by Category",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppTheme.surfaceBlack,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              dropdownColor: AppTheme.surfaceBlack,
              style: TextStyle(color: AppTheme.primaryWhite),
              value: provider.selectedCategory,
              items:
                  provider.availableCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(color: AppTheme.primaryWhite),
                          ),
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
      color: AppTheme.cardBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Category Breakdown",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
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
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryWhite,
                      ),
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(0)} ($percentage%)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.lightGrey,
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

  Widget _buildInsights(StatsProvider provider) {
    final totalSpending = provider.getTotalSpending();
    final pending = provider.getPendingPayments();

    return Card(
      elevation: 3,
      color: AppTheme.cardBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Insights",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryWhite,
              ),
            ),
            SizedBox(height: 12),
            _buildInsightItem(
              Icons.trending_up,
              "Monthly Spending",
              "₹${totalSpending.toStringAsFixed(0)} this month",
              AppTheme.primaryWhite,
            ),
            if (pending > 0)
              _buildInsightItem(
                Icons.schedule,
                "Pending Payments",
                "₹${pending.toStringAsFixed(0)} to settle",
                AppTheme.warningOrange,
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
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryWhite,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateInterval(List<Map<String, dynamic>> graphData) {
    if (graphData.isEmpty) return 1000;
    
    final maxAmount = graphData
        .map((e) => e['amount'] as double)
        .reduce((a, b) => a > b ? a : b);
    
    if (maxAmount < 1000) return 200;
    if (maxAmount < 5000) return 1000;
    if (maxAmount < 10000) return 2000;
    return 5000;
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
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryWhite,
              onPrimary: AppTheme.primaryBlack,
              surface: AppTheme.cardBlack,
              onSurface: AppTheme.primaryWhite,
            ),
            dialogBackgroundColor: AppTheme.cardBlack,
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
      backgroundColor: AppTheme.cardBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryWhite,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.file_download, color: AppTheme.primaryWhite),
                title: Text(
                  'Export as PDF',
                  style: TextStyle(color: AppTheme.primaryWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement PDF export
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart, color: AppTheme.primaryWhite),
                title: Text(
                  'Export as CSV',
                  style: TextStyle(color: AppTheme.primaryWhite),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement CSV export
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
