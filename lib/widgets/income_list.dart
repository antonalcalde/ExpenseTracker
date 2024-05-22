import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import './income_card.dart';

class IncomeList extends StatelessWidget {
  const IncomeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (_, db, __) {
        var list = db.incomes;
        return list.isNotEmpty
            ? ListView.builder(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemCount: list.length,
          itemBuilder: (_, i) => IncomeCard(list[i]),
        )
            : const Center(
          child: Text('No Incomes Found'),
        );
      },
    );
  }
}
