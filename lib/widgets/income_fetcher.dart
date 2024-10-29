import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import './income_list.dart';

class IncomeFetcher extends StatefulWidget {
  const IncomeFetcher({super.key});

  @override
  State<IncomeFetcher> createState() => _IncomeFetcherState();
}

class _IncomeFetcherState extends State<IncomeFetcher> {
  late Future _incomeList;

  Future _getIncomeList() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return await provider.fetchIncomes();
  }

  @override
  void initState() {
    super.initState();
    _incomeList = _getIncomeList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _incomeList,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const IncomeList();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
