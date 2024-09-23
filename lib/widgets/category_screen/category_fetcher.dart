import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/database_provider.dart';
import './total_chart.dart';
import './category_list.dart';
import '../../screens/all_expenses.dart';

class CategoryFetcher extends StatefulWidget {
  const CategoryFetcher({super.key});

  @override
  State<CategoryFetcher> createState() => _CategoryFetcherState();
}

class _CategoryFetcherState extends State<CategoryFetcher> {
  late Future _categoryList;

Future _getCategoryList() async {
  try {
    final provider = context.read<DatabaseProvider>();
    return await provider.fetchCategories();
  } catch (e) {
    print('Error fetching categories: $e');
    return Future.error(e);
  }
}

@override
void initState() {
  super.initState();
  // fetch the list and set it to _categoryList
  _categoryList = _getCategoryList();
  print('Fetching categories...');
  context.read<DatabaseProvider>().fetchCategories();
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _categoryList,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // if connection is done then check for errors or return the result
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 200.0,
                    child: TotalChart(), // Removed const
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expenses',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AllExpenses.name);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  Expanded(child: CategoryList()), // Removed const
                ],
              ),
            );
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
