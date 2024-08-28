import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/category_screen/category_fetcher.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_form.dart';
import '../screens/income_screen.dart';
import '../models/database_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  static const name = '/category_screen'; // for routes

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _currentExpenseType = 'Today\'s Expenses';
  double _currentExpenseValue = 0.0;

  @override
  void initState() {
    super.initState();
    _updateExpenseValue();
  }

  void _updateExpenseValue() {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final today = DateTime.now();

    setState(() {
      if (_currentExpenseType == 'Today\'s Expenses') {
        _currentExpenseValue = dbProvider.calculateDailyExpenses(today);
      } else if (_currentExpenseType == 'Weekly Expenses') {
        _currentExpenseValue = dbProvider.calculateWeekExpenses().fold(0.0, (sum, day) => sum + day['amount']);
      } else if (_currentExpenseType == 'Monthly Expenses') {
        _currentExpenseValue = dbProvider.calculateMonthlyExpenses(today.month, today.year);
      } else if (_currentExpenseType == 'Yearly Expenses') {
        _currentExpenseValue = dbProvider.calculateYearlyExpenses(today.year);
      }
    });
  }

  void _toggleExpenseType() {
    setState(() {
      if (_currentExpenseType == 'Today\'s Expenses') {
        _currentExpenseType = 'Weekly Expenses';
      } else if (_currentExpenseType == 'Weekly Expenses') {
        _currentExpenseType = 'Monthly Expenses';
      } else if (_currentExpenseType == 'Monthly Expenses') {
        _currentExpenseType = 'Yearly Expenses';
      } else if (_currentExpenseType == 'Yearly Expenses') {
        _currentExpenseType = 'Today\'s Expenses';
      }
      _updateExpenseValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/wealthcast_logo.png',
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Wealthcast',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<DatabaseProvider>(
              builder: (context, dbProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _toggleExpenseType, // Toggle the expense type on tap
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Light grey background
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentExpenseType,
                                style: const TextStyle(
                                  fontSize: 12, // Smaller font size
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4), // Small space between the label and value
                              Text(
                                '₱ ${_currentExpenseValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24, // Larger font size for the value
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // Add space between the container and button
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const ExpenseForm(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(10.0),
                        shape: const CircleBorder(),
                        backgroundColor: Colors.green, // Updated parameter
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                );
              },
            ),
          ),
          const Expanded(child: CategoryFetcher()), // Ensure this is expanded to take up available space
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const IncomeForm(),
              );
            },
            heroTag: 'income',
            child: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed(IncomeScreen.name);
            },
            heroTag: 'view_income',
            child: const Icon(Icons.account_balance_wallet),
          ),
        ],
      ),
    );
  }
}
