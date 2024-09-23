import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ex_category.dart';
import '../../screens/expense_screen.dart';

class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  final int index; // Add index parameter
  final List<Color> colors; // Add colors list parameter
  final double percentage; // Add percentage parameter

  const CategoryCard(this.category, this.index, this.colors, this.percentage, {super.key}); // Modify constructor

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            ExpenseScreen.name,
            arguments: category.title, // for expensescreen.
          );
        },
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: colors[index % colors.length], // Set background color from the color list
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              category.icon,
              size: 30,
              color: Colors.white, // Use white color for contrast
            ),
          ),
        ),
        title: Text(
          category.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
        ),
        subtitle: Text(
          'Entries: ${category.entries}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(locale: 'en_IN', symbol: '₱')
                  .format(category.totalAmount),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(2)}%', // Display the percentage here
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}