import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/icons.dart';
import './ex_category.dart';
import './expense.dart';
import './income.dart';

class DatabaseProvider with ChangeNotifier {
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _searchText.isNotEmpty
      ? _expenses.where((e) => e.title.toLowerCase().contains(_searchText.toLowerCase())).toList()
      : _expenses;

  List<Income> _incomes = [];
  List<Income> get incomes => _incomes;

  double get totalExpenses => _categories.fold(0.0, (sum, item) => sum + item.totalAmount);

  // Base API URL (Change this to your Flask server address)
  final String apiUrl = 'http://10.0.2.2:5000';

  // Fetch all categories from Flask API
  Future<List<ExpenseCategory>> fetchCategories() async {
    final response = await http.get(Uri.parse('$apiUrl/categories'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _categories = List<ExpenseCategory>.from(data.map((item) => ExpenseCategory.fromString(item)));
      notifyListeners();
      return _categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Add a new expense via Flask API
  Future<void> addExpense(Expense exp) async {
    final response = await http.post(
      Uri.parse('$apiUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(exp.toMap()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final newExpense = exp.copyWith(id: data['id']);
      _expenses.add(newExpense);
      notifyListeners();
      await updateCategory(exp.category, findCategory(exp.category).entries + 1, findCategory(exp.category).totalAmount + exp.amount);
    } else {
      throw Exception('Failed to add expense');
    }
  }

  // Delete an expense via Flask API
  Future<void> deleteExpense(int expId, String category, double amount) async {
    final response = await http.delete(Uri.parse('$apiUrl/expenses/$expId'));

    if (response.statusCode == 200) {
      _expenses.removeWhere((element) => element.id == expId);
      notifyListeners();
      var ex = findCategory(category);
      await updateCategory(category, ex.entries - 1, ex.totalAmount - amount);
    } else {
      throw Exception('Failed to delete expense');
    }
  }

  // Fetch all expenses from Flask API
  Future<List<Expense>> fetchExpenses(String category) async {
    final response = await http.get(Uri.parse('$apiUrl/expenses?category=$category'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _expenses = List<Expense>.from(data.map((item) => Expense.fromString(item)));
      notifyListeners();
      return _expenses;
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  // Fetch all expenses
  Future<List<Expense>> fetchAllExpenses() async {
    final response = await http.get(Uri.parse('$apiUrl/expenses'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _expenses = List<Expense>.from(data.map((item) => Expense.fromString(item)));
      notifyListeners();
      return _expenses;
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  // Find category by title
  ExpenseCategory findCategory(String title) {
    return _categories.firstWhere((element) => element.title == title);
  }

  // Update a category via Flask API
  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    final response = await http.put(
      Uri.parse('$apiUrl/categories/$category'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'entries': nEntries, 'totalAmount': nTotalAmount.toString()}),
    );

    if (response.statusCode == 200) {
      var file = _categories.firstWhere((element) => element.title == category);
      file.entries = nEntries;
      file.totalAmount = nTotalAmount;
      notifyListeners();
    } else {
      throw Exception('Failed to update category');
    }
  }
  // Calculate daily expenses via Flask API
  Future<double> calculateDailyExpenses(DateTime date) async {
    final response = await http.get(
      Uri.parse('$apiUrl/expenses/daily?year=${date.year}&month=${date.month}&day=${date.day}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['totalAmount'];
    } else {
      throw Exception('Failed to calculate daily expenses');
    }
  }

// Calculate weekly expenses via Flask API
Future<double> calculateWeekExpenses(DateTime startDate) async {
  final monday = startDate.subtract(Duration(days: startDate.weekday - 1)); // Get Monday of the current week
  final sunday = monday.add(const Duration(days: 6)); // Get Sunday of the current week

  final response = await http.get(
    Uri.parse(
      '$apiUrl/expenses/weekly?startDate=${monday.toIso8601String()}&endDate=${sunday.toIso8601String()}',
    ),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['totalAmount'];
  } else {
    throw Exception('Failed to calculate weekly expenses');
  }
}

    // Calculate monthly expenses via Flask API
  Future<double> calculateMonthlyExpenses(int month, int year) async {
    final response = await http.get(
      Uri.parse('$apiUrl/expenses/monthly?year=$year&month=$month'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['totalAmount'];
    } else {
      throw Exception('Failed to calculate monthly expenses');
    }
  }

  // Calculate yearly expenses via Flask API
  Future<double> calculateYearlyExpenses(int year) async {
    final response = await http.get(
      Uri.parse('$apiUrl/expenses/yearly?year=$year'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['totalAmount'];
    } else {
      throw Exception('Failed to calculate yearly expenses');
    }
  }
  // Fetch all incomes from Flask API
  Future<List<Income>> fetchIncomes() async {
    final response = await http.get(Uri.parse('$apiUrl/incomes'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _incomes = List<Income>.from(data.map((item) => Income.fromString(item)));
      notifyListeners();
      return _incomes;
    } else {
      throw Exception('Failed to load incomes');
    }
  }

  // Add new income via Flask API
  Future<void> addIncome(Income income) async {
    final response = await http.post(
      Uri.parse('$apiUrl/incomes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(income.toMap()),
    );

    if (response.statusCode == 201) {
      _incomes.add(income);
      notifyListeners();
    } else {
      throw Exception('Failed to add income');
    }
  }

  // Delete income via Flask API
  Future<void> deleteIncome(int incomeId) async {
    final response = await http.delete(Uri.parse('$apiUrl/incomes/$incomeId'));

    if (response.statusCode == 200) {
      _incomes.removeWhere((element) => element.id == incomeId);
      notifyListeners();
    } else {
      throw Exception('Failed to delete income');
    }
  }

  // Calculate net savings (locally based on fetched data)
  double calculateNetSavings() {
    return calculateTotalIncomes() - calculateTotalExpenses();
  }

  // Calculate total expenses (locally)
  double calculateTotalExpenses() {
    return _categories.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  // Calculate total incomes (locally)
  double calculateTotalIncomes() {
    return _incomes.fold(0.0, (sum, item) => sum + item.amount);
  }

  // Calculate entries and total amount for a specific category via Flask API
  Future<Map<String, dynamic>> calculateEntriesAndAmount(String category) async {
    final response = await http.get(
      Uri.parse('$apiUrl/expenses/category?category=$category'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'entries': data['entries'],
        'totalAmount': data['totalAmount']
      };
    } else {
      throw Exception('Failed to calculate entries and amount');
    }
  }
}
