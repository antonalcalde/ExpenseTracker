import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

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

Future<Map<String, dynamic>> fetchExpenseData() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/expenses/total'),
      headers: {
        'Cache-Control': 'no-cache',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      print('Error fetching expense data: ${response.statusCode}');
      throw Exception('Failed to fetch expense data');
    }
  } catch (e) {
    print('Error fetching expense data: $e');
    throw Exception('Failed to fetch expense data');
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchExpenseData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var expenseData = snapshot.data;
          var categories = expenseData?['categories'] ?? [];
          var totalExpenses = (expenseData?['totalExpenses'] ?? 0.0).toDouble();

          if (categories.isEmpty) {
            return const Center(child: Text('No categories found'));
          }
          if (totalExpenses == 0.0) {
            return const Center(child: Text('Total expenses is zero'));
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
                    ...categories.map(
                      (category) {
                        double index = categories.indexOf(category).toDouble();
                        double totalAmount = (category['totalAmount'] ?? 0.0).toDouble();

                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                color: _colors[(index % _colors.length).toInt()], // Cast back to int for color access
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                category['title'],
                              ),
                              const SizedBox(width: 5.0),
                              Text('${((totalAmount / totalExpenses) * 100).toStringAsFixed(2)}%'),
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
                    sections: categories.map<PieChartSectionData>(
                      (category) {
                        double index = categories.indexOf(category).toDouble();
                        double totalAmount = (category['totalAmount'] ?? 0.0).toDouble();

                        return PieChartSectionData(
                          showTitle: false,
                          value: totalAmount,
                          color: _colors[(index % _colors.length).toInt()], // Cast back to int for color access
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}