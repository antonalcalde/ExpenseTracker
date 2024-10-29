import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/database_provider.dart';
import '../models/income.dart';

class IncomeForm extends StatefulWidget {
  const IncomeForm({super.key});

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _title = TextEditingController();
  final _amount = TextEditingController();
  DateTime? _date;

  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

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
              'Add New Income',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'Title of income',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount of income',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
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
            const SizedBox(height: 30.0),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_title.text.isNotEmpty && _amount.text.isNotEmpty) {
                    final income = Income(
                      id: 0,
                      title: _title.text,
                      amount: double.parse(_amount.text),
                      date: _date != null ? _date! : DateTime.now(),
                    );
                    provider.addIncome(income);
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Income'),
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
