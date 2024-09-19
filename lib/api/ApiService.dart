import 'package:flutter/material.dart';
import 'api_service.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService apiService = ApiService('http://127.0.0.1:5000'); // Update with your Flask backend URL
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      final fetchedCategories = await apiService.getCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      // Handle error
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category['title']),
            subtitle: Text('Entries: ${category['entries']}, Total Amount: ${category['total_amount']}'),
          );
        },
      ),
    );
  }
}
