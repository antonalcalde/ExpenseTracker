import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import './confirm_box.dart';

class IncomeCard extends StatelessWidget {
  final Income income;
  const IncomeCard(this.income, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(income.id),
      confirmDismiss: (_) async {
        showDialog(
          context: context,
          builder: (_) => ConfirmBox(income: income),
        );
      },
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.attach_money),
        ),
        title: Text(income.title),
        subtitle: Text(DateFormat('MMMM dd, yyyy').format(income.date)),
        trailing: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₱')
            .format(income.amount)),
      ),
    );
  }
}
