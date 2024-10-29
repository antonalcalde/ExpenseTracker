import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';

class TotalChart extends StatefulWidget {
  const TotalChart({super.key});

  @override
  State<TotalChart> createState() => _TotalChartState();
}

class _TotalChartState extends State<TotalChart> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('type', isEqualTo: 2)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenseData = snapshot.data!.docs;

        return Row(
          children: [
            Expanded(
              flex: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: expenseData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(3),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                color: Color(int.parse(
                                    '0x${expenseData[index]['color']}')),
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                expenseData[index]['name'],
                              ),
                              const SizedBox(width: 5.0),
                              Text('0%')
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 40,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 20.0,
                  sections: expenseData.map<PieChartSectionData>((e) {
                    return PieChartSectionData(
                      showTitle: false,
                      value: 30,
                      color: Color(int.parse('0x${e['color']}')),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
