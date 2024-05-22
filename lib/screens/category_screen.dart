import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/category_screen/category_fetcher.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_form.dart';
import '../screens/income_screen.dart';
import '../models/database_provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  static const name = '/category_screen'; // for routes

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
              builder: (context, dbProvider, child) => Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Light grey background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Expenses: ₱ ${dbProvider.totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                ),
              ),
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
