import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';

class TotalChart extends StatefulWidget {
  const TotalChart({super.key});

  @override
  State<TotalChart> createState() => _TotalChartState();
}

class _TotalChartState extends State<TotalChart> {
  // Define a list of distinct colors
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
      var total = db.calculateTotalExpenses();
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
                          Text(
                            e.title,
                          ),
                          const SizedBox(width: 5.0),
                          Text(total == 0
                              ? '0%'
                              : '${((e.totalAmount / total) * 100).toStringAsFixed(2)}%'),
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
                    ? list
                    .map(
                      (e) {
                    int index = list.indexOf(e);
                    return PieChartSectionData(
                      showTitle: false,
                      value: e.totalAmount,
                      color: _colors[index % _colors.length],
                    );
                  },
                )
                    .toList()
                    : list
                    .map(
                      (e) {
                    int index = list.indexOf(e);
                    return PieChartSectionData(
                      showTitle: false,
                      color: _colors[index % _colors.length],
                    );
                  },
                )
                    .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}
