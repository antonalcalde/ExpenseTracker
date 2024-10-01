import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
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
  String _currentExpenseType = 'Daily Expenses'; // Initialize with Daily Expenses
  double _currentExpenseValue = 0.0;
  String _currentExpenseDateRange = ''; // To display the date range
  DateTime? _selectedDate; // To track the selected date

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Initialize with today's date
    _updateExpenseValue();
  }

  // Date Picker Function
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _updateExpenseValue(); // Update the expense data after date selection
      });
    }
  }

void _updateExpenseValue() {
  final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
  final today = _selectedDate ?? DateTime.now();
  final dateFormatter = DateFormat('MMMM d, yyyy');

  setState(() {
    if (_currentExpenseType == 'Daily Expenses') {
      _currentExpenseValue = dbProvider.calculateDailyExpenses(today);
      _currentExpenseDateRange = dateFormatter.format(today); // Format for daily expenses
    } else if (_currentExpenseType == 'Today\'s Expenses') {
      _currentExpenseValue = dbProvider.calculateDailyExpenses(today);
      _currentExpenseDateRange = dateFormatter.format(today); // Format for today's expenses
    } else if (_currentExpenseType == 'Weekly Expenses') {
      final monday = today.subtract(Duration(days: today.weekday - 1)); // Get Monday of the current week
      final sunday = monday.add(const Duration(days: 6)); // Get Sunday of the current week
      _currentExpenseValue = dbProvider.calculateWeekExpenses().fold(0.0, (sum, day) => sum + day['amount']);
      _currentExpenseDateRange = '${dateFormatter.format(monday)} - ${dateFormatter.format(sunday)}'; // Format for weekly expenses
    } else if (_currentExpenseType == 'Monthly Expenses') {
      _currentExpenseValue = dbProvider.calculateMonthlyExpenses(today.month, today.year);
      _currentExpenseDateRange = DateFormat('MMMM yyyy').format(today); // Format for monthly expenses
    } else if (_currentExpenseType == 'Yearly Expenses') {
      _currentExpenseValue = dbProvider.calculateYearlyExpenses(today.year);
      _currentExpenseDateRange = today.year.toString(); // Format for yearly expenses
    }
  });
}


void _toggleExpenseType() {
  setState(() {
    if (_currentExpenseType == 'Daily Expenses') {
      _currentExpenseType = 'Today\'s Expenses';
    } else if (_currentExpenseType == 'Today\'s Expenses') {
      _currentExpenseType = 'Weekly Expenses';
    } else if (_currentExpenseType == 'Weekly Expenses') {
      _currentExpenseType = 'Monthly Expenses';
    } else if (_currentExpenseType == 'Monthly Expenses') {
      _currentExpenseType = 'Yearly Expenses';
    } else if (_currentExpenseType == 'Yearly Expenses') {
      _currentExpenseType = 'Daily Expenses'; // Cycle back to Daily Expenses
    }
    _updateExpenseValue();
  });
}


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // We have 4 tabs
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Income'),
              Tab(text: 'Expenses'),
              Tab(text: 'Predictions'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Income Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const IncomeForm(),
                      );
                    },
                    child: const Text('Add Income'),
                  ),
                  const SizedBox(height: 20), // Space between buttons
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(IncomeScreen.name);
                    },
                    child: const Text('View All Income'),
                  ),
                ],
              ),
            ),

            // Expenses Tab (Current content moved here)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<DatabaseProvider>(builder: (context, dbProvider, child) {
                    return Row(
                      children: [
                        // Display Expense Type and Value
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
                                  const SizedBox(height: 4), // Space between value and date range
                                  Text(
                                    _currentExpenseDateRange,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Space between container and calendar icon
                        // Calendar Icon for Date Picker
                        IconButton(
                          onPressed: _pickDate, // Opens the date picker
                          icon: const Icon(Icons.calendar_today),
                          tooltip: 'Pick a date',
                        ),
                        const SizedBox(width: 16), // Space between calendar icon and button
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
                  }),
                ),
                const Expanded(child: CategoryFetcher()), // Ensure this is expanded to take up available space
              ],
            ),

            // Predictions Tab
            Center(
              child: Text('Predictions Content'),
            ),

            // Settings Tab
            Center(
              child: Text('Settings Content'),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleExpenseType, // Switch between expense types
          tooltip: 'Switch Expense Type',
          child: const Icon(Icons.swap_horiz), // Use any icon you prefer
        ),
      ),
    );
  }
}
