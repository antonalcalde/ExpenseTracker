import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/database_provider.dart';
import '../constants/icons.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _date;
  String _initialValue = 'Other';

  //
  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime.now());

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Expense',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            // title
            TextField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'Title of expense',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // amount
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount of expense',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            // date picker
            Row(
              children: [
                Expanded(
                  child: Text(
                    _date != null
                        ? DateFormat('MMMM dd, yyyy').format(_date!)
                        : 'Select Date',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => _pickDate(),
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // category
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Category',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    items: icons.keys
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    value: _initialValue,
                    onChanged: (newValue) {
                      setState(() {
                        _initialValue = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_title.text.isNotEmpty && _amount.text.isNotEmpty) {
                    // create an expense
                    final expense = Expense(
                      id: 0,
                      title: _title.text,
                      amount: double.parse(_amount.text),
                      date: _date != null ? _date! : DateTime.now(),
                      category: _initialValue,
                    );
                    // add it to database.
                    provider.addExpense(expense);
                    // close the bottomsheet
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Expense'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
