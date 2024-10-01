import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';

class TotalChart extends StatefulWidget {
  final String expenseType; // Add this property to receive the type of expenses (daily, weekly, etc.)
  
  const TotalChart({super.key, required this.expenseType});

  @override
  State<TotalChart> createState() => _TotalChartState();
}

class _TotalChartState extends State<TotalChart> {
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.brown,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(builder: (_, db, __) {
      var list = db.categories;

      // Initialize expenses variable
      List<double> expenses = List.filled(list.length, 0.0); 
      double total = 0.0; // Initialize total expense variable

      // Get the data based on the current expense type
if (widget.expenseType == 'Today\'s Expenses') {
  DateTime today = DateTime.now();
  for (var expense in db.expenses.where((expense) =>
      expense.date.year == today.year &&
      expense.date.month == today.month &&
      expense.date.day == today.day)) {
    int index = list.indexWhere((element) => element.title == expense.category);
    if (index != -1) {
      expenses[index] += expense.amount;
      total += expense.amount;
    }
  }

} else if (widget.expenseType == 'Monthly Expenses') {
  int month = DateTime.now().month;
  int year = DateTime.now().year;
  for (var expense in db.expenses.where((expense) =>
      expense.date.year == year && expense.date.month == month)) {
    int index = list.indexWhere((element) => element.title == expense.category);
    if (index != -1) {
      expenses[index] += expense.amount;
      total += expense.amount;
    }
  }
  total = db.calculateMonthlyExpenses(month, year); // Update total with the correct value
} else if (widget.expenseType == 'Yearly Expenses') {
  int year = DateTime.now().year;
  for (var expense in db.expenses.where((expense) => expense.date.year == year)) {
    int index = list.indexWhere((element) => element.title == expense.category);
    if (index != -1) {
      expenses[index] += expense.amount;
      total += expense.amount;
    }
  }
  total = db.calculateYearlyExpenses(year); // Update total with the correct value
}

      return Row(
        children: [
          Expanded(
            flex: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                ...list.map(
                  (e) {
                    int index = list.indexOf(e);
                    return Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            color: _colors[index % _colors.length],
                          ),
                          const SizedBox(width: 5.0),
                          Text(e.title),
                          const SizedBox(width: 5.0),
                          Text(total == 0
                              ? '0%'
                              : '${((expenses[index] / total) * 100).toStringAsFixed(2)}%'),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ],
            ),
          ),
          Expanded(
            flex: 40,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 20.0,
                sections: total != 0
                    ? list.map(
                        (e) {
                          int index = list.indexOf(e);
                          return PieChartSectionData(
                            showTitle: false,
                            value: expenses[index],
                            color: _colors[index % _colors.length],
                          );
                        },
                      ).toList()
                    : list.map(
                        (e) {
                          int index = list.indexOf(e);
                          return PieChartSectionData(
                            showTitle: false,
                            color: _colors[index % _colors.length],
                          );
                        },
                      ).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}