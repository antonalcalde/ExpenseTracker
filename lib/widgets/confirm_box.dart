import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import '../models/expense.dart';
import '../models/income.dart';

class ConfirmBox extends StatelessWidget {
  final Expense? exp;
  final Income? income;

  const ConfirmBox({Key? key, this.exp, this.income}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return AlertDialog(
      title: Text('Delete ${exp?.title ?? income?.title} ?'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // don't delete
            },
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 5.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // delete
              if (exp != null) {
                provider.deleteExpense(exp!.id, exp!.category, exp!.amount);
              } else if (income != null) {
                provider.deleteIncome(income!.id);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
