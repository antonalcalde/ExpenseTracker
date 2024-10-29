import 'package:flutter/material.dart';
import '../widgets/income_fetcher.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});
  static const name = '/income_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Incomes')),
      body: const IncomeFetcher(),
    );
  }
}
