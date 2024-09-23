import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import './category_card.dart';

class CategoryList extends StatelessWidget {
  CategoryList({Key? key}) : super(key: key); // Removed const

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
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        // Get the categories
        var list = db.categories;
        return FutureBuilder(
          future: db.calculateTotalExpenses(), // Total expenses
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var total = snapshot.data; // total expenses
              return ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  // Calculate percentage for each category
                 final double percentage = total == 0
                       ? 0
                       : (list[i].totalAmount.toDouble() / total!) * 100;
                  
                  // Pass the category, index, color list, and percentage
                  return CategoryCard(
                    list[i], // category
                    i, // index
                    _colors, // colors list
                    percentage, // percentage value
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }
}