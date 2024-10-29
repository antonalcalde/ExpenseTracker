import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_app/screens/all_settings.dart';
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
  String _currentExpenseType = 'Today\'s Expenses';
  double _currentExpenseValue = 0.0;
  String _currentExpenseDateRange = ''; // To display the date range
  DateTime? _selectedDate; // To track the selected date
  final savingsGoalController = TextEditingController();
  final goalDateController = TextEditingController();
  final predictDateController = TextEditingController();

  void initialize_data() async {
    final docSnapshot =
        await FirebaseFirestore.instance.collection('goals').doc('0').get();

    final data = docSnapshot.data();

    savingsGoalController.text = data!['savings'] ?? '0';
    goalDateController.text = data['goal_date'] ?? '';
    predictDateController.text = data['predict_date'] ?? '';

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Initialize with today's date
    _updateExpenseValue();
    initialize_data();
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
      if (_currentExpenseType == 'Today\'s Expenses') {
        _currentExpenseValue = dbProvider.calculateDailyExpenses(today);
        _currentExpenseDateRange =
            dateFormatter.format(today); // Format for daily expenses
      } else if (_currentExpenseType == 'Weekly Expenses') {
        final monday = today.subtract(Duration(
            days: today.weekday - 1)); // Get Monday of the current week
        final sunday = monday
            .add(const Duration(days: 6)); // Get Sunday of the current week
        _currentExpenseValue = dbProvider
            .calculateWeekExpenses()
            .fold(0.0, (sum, day) => sum + day['amount']);
        _currentExpenseDateRange =
            '${dateFormatter.format(monday)} - ${dateFormatter.format(sunday)}'; // Format for weekly expenses
      } else if (_currentExpenseType == 'Monthly Expenses') {
        _currentExpenseValue =
            dbProvider.calculateMonthlyExpenses(today.month, today.year);
        _currentExpenseDateRange = DateFormat('MMMM yyyy')
            .format(today); // Format for monthly expenses
      } else if (_currentExpenseType == 'Yearly Expenses') {
        _currentExpenseValue = dbProvider.calculateYearlyExpenses(today.year);
        _currentExpenseDateRange =
            today.year.toString(); // Format for yearly expenses
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
                  child: Consumer<DatabaseProvider>(
                    builder: (context, dbProvider, child) {
                      return Row(
                        children: [
                          // Display Expense Type and Value
                          Expanded(
                            child: GestureDetector(
                              onTap:
                                  _toggleExpenseType, // Toggle the expense type on tap
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey[200], // Light grey background
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
                                    const SizedBox(
                                        height:
                                            4), // Small space between the label and value
                                    Text(
                                      '₱ ${_currentExpenseValue.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize:
                                            24, // Larger font size for the value
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            4), // Space between value and date range
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
                          const SizedBox(
                              width:
                                  16), // Space between container and calendar icon
                          // Calendar Icon for Date Picker
                          IconButton(
                            onPressed: _pickDate, // Opens the date picker
                            icon: const Icon(Icons.calendar_today),
                            tooltip: 'Pick a date',
                          ),
                          const SizedBox(
                              width:
                                  16), // Space between calendar icon and button
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
                              backgroundColor:
                                  Colors.green, // Updated parameter
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Expanded(
                    child:
                        CategoryFetcher()), // Ensure this is expanded to take up available space
              ],
            ),

            // Predictions Tab
            const Center(
              child: Text('Predictions Content'),
            ),

            // Settings Tab
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AllSettings(type: 1))),
                    leading: Container(
                      decoration: BoxDecoration(
                          color: Colors.green[300],
                          borderRadius: BorderRadius.circular(5)),
                      width: 30,
                      height: 30,
                    ),
                    title: Text('Income Categories'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AllSettings(type: 2))),
                    leading: Container(
                      decoration: BoxDecoration(
                          color: Colors.orange[300],
                          borderRadius: BorderRadius.circular(5)),
                      width: 30,
                      height: 30,
                    ),
                    title: Text('Expense Categories'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Savings Goal'),
                        content: TextFormField(
                          controller: savingsGoalController,
                          decoration: InputDecoration(hintText: 'Savings'),
                          keyboardType: TextInputType.number,
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('goals')
                                    .doc('0')
                                    .update({
                                  'savings': savingsGoalController.text.trim()
                                });

                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Done'))
                        ],
                      ),
                    ),
                    leading: Container(
                      decoration: BoxDecoration(
                          color: Colors.purple[300],
                          borderRadius: BorderRadius.circular(5)),
                      width: 30,
                      height: 30,
                    ),
                    title: Text('Savings Goal'),
                    trailing: Text(
                      savingsGoalController.text.isEmpty
                          ? 'N/A'
                          : savingsGoalController.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Goal Date'),
                        content: TextFormField(
                          readOnly: true,
                          controller: goalDateController,
                          decoration: InputDecoration(hintText: 'Date'),
                          keyboardType: TextInputType.number,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('MMMM d, y').format(pickedDate);
                              setState(() {
                                goalDateController.text = formattedDate;
                              });
                            }
                          },
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('goals')
                                    .doc('0')
                                    .update({
                                  'goal_date': goalDateController.text.trim()
                                });

                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Done'))
                        ],
                      ),
                    ),
                    leading: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.circular(5)),
                      width: 30,
                      height: 30,
                    ),
                    title: Text('Goal Date'),
                    trailing: Text(
                      goalDateController.text.isEmpty
                          ? 'N/A'
                          : goalDateController.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Predict Date'),
                        content: TextFormField(
                          readOnly: true,
                          controller: predictDateController,
                          decoration: InputDecoration(hintText: 'Date'),
                          keyboardType: TextInputType.number,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              String formattedDate =
                                  DateFormat('MMMM d, y').format(pickedDate);
                              setState(() {
                                predictDateController.text = formattedDate;
                              });
                            }
                          },
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('goals')
                                    .doc('0')
                                    .update({
                                  'predict_date':
                                      predictDateController.text.trim()
                                });

                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                              child: Text('Done'))
                        ],
                      ),
                    ),
                    leading: Container(
                      decoration: BoxDecoration(
                          color: Colors.teal[300],
                          borderRadius: BorderRadius.circular(5)),
                      width: 30,
                      height: 30,
                    ),
                    title: Text('Predict Until'),
                    trailing: Text(
                      predictDateController.text.isEmpty
                          ? 'N/A'
                          : predictDateController.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
