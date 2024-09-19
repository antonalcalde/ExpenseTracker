import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/database_provider.dart';

class ExpenseChart extends StatefulWidget {
  final String category;
  const ExpenseChart(this.category, {super.key});

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  Future<Map<String, dynamic>>? _entriesAndAmountFuture;
  Future<double>? _weeklyExpensesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    _entriesAndAmountFuture = dbProvider.calculateEntriesAndAmount(widget.category);

    // Pass today's date to calculate the weekly expenses
    final today = DateTime.now();
    _weeklyExpensesFuture = dbProvider.calculateWeekExpenses(today);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, db, __) {
      return FutureBuilder<Map<String, dynamic>>(
        future: _entriesAndAmountFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final maxY = snapshot.data!['totalAmount'];

          return FutureBuilder<double>(
            future: _weeklyExpensesFuture,
            builder: (context, weekSnapshot) {
              if (weekSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (weekSnapshot.hasError) {
                return Center(child: Text('Error: ${weekSnapshot.error}'));
              } else if (!weekSnapshot.hasData) {
                return Center(child: Text('No data available'));
              }

              final totalWeeklyExpenses = weekSnapshot.data!;

              // Since we don't need detailed breakdown, just display total weekly expenses as a single bar
              return BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  barGroups: [
                    BarChartGroupData(
                      x: 0, // Single bar for total weekly expenses
                      barRods: [
                        BarChartRodData(
                          toY: totalWeeklyExpenses,
                          width: 20.0,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      drawBehindEverything: true,
                    ),
                    leftTitles: AxisTitles(
                      drawBehindEverything: true,
                    ),
                    rightTitles: AxisTitles(
                      drawBehindEverything: true,
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) =>
                            Text('Weekly Expenses'),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }
}
