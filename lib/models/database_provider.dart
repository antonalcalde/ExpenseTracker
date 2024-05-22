import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/icons.dart';
import './ex_category.dart';
import './expense.dart';
import './income.dart'; // Import the Income model

class DatabaseProvider with ChangeNotifier {
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  // In-app memory for holding the Expense categories temporarily
  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expenses = [];
  List<Expense> get expenses {
    return _searchText != ''
        ? _expenses.where((e) => e.title.toLowerCase().contains(_searchText.toLowerCase())).toList()
        : _expenses;
  }

  List<Income> _incomes = [];
  List<Income> get incomes => _incomes;

  double get totalExpenses {
    return _categories.fold(
      0.0,
          (previousValue, element) => previousValue + element.totalAmount,
    );
  }

  Database? _database;
  Future<Database> get database async {
    final dbDirectory = await getDatabasesPath();
    const dbName = 'expense_tc.db';
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 2, // Incremented database version
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );

    return _database!;
  }

  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  static const iTable = 'incomeTable';

  Future<void> _createDb(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''CREATE TABLE $cTable(
        title TEXT,
        entries INTEGER,
        totalAmount TEXT
      )''');
      await txn.execute('''CREATE TABLE $eTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT,
        category TEXT
      )''');
      await txn.execute('''CREATE TABLE $iTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT
      )''');

      for (int i = 0; i < icons.length; i++) {
        await txn.insert(cTable, {
          'title': icons.keys.toList()[i],
          'entries': 0,
          'totalAmount': (0.0).toString(),
        });
      }
    });
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''CREATE TABLE $iTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT
      )''');
    }
  }

  Future<List<ExpenseCategory>> fetchCategories() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(cTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<ExpenseCategory> nList = List.generate(
          converted.length,
              (index) => ExpenseCategory.fromString(converted[index]),
        );
        _categories = nList;
        return _categories;
      });
    });
  }

  Future<void> updateCategory(
      String category,
      int nEntries,
      double nTotalAmount,
      ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        cTable,
        {
          'entries': nEntries,
          'totalAmount': nTotalAmount.toString(),
        },
        where: 'title == ?',
        whereArgs: [category],
      ).then((_) {
        var file = _categories.firstWhere((element) => element.title == category);
        file.entries = nEntries;
        file.totalAmount = nTotalAmount;
        notifyListeners();
      });
    });
  }

  Future<void> addExpense(Expense exp) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        eTable,
        exp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      ).then((generatedId) {
        final file = Expense(
          id: generatedId,
          title: exp.title,
          amount: exp.amount,
          date: exp.date,
          category: exp.category,
        );
        _expenses.add(file);
        notifyListeners();
        var ex = findCategory(exp.category);
        updateCategory(exp.category, ex.entries + 1, ex.totalAmount + exp.amount);
      });
    });
  }

  Future<void> deleteExpense(int expId, String category, double amount) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(eTable, where: 'id == ?', whereArgs: [expId]).then((_) {
        _expenses.removeWhere((element) => element.id == expId);
        notifyListeners();
        var ex = findCategory(category);
        updateCategory(category, ex.entries - 1, ex.totalAmount - amount);
      });
    });
  }

  Future<List<Expense>> fetchExpenses(String category) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable, where: 'category == ?', whereArgs: [category]).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<Expense> nList = List.generate(
          converted.length,
              (index) => Expense.fromString(converted[index]),
        );
        _expenses = nList;
        return _expenses;
      });
    });
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<Expense> nList = List.generate(
          converted.length,
              (index) => Expense.fromString(converted[index]),
        );
        _expenses = nList;
        return _expenses;
      });
    });
  }

  ExpenseCategory findCategory(String title) {
    return _categories.firstWhere((element) => element.title == title);
  }

  Map<String, dynamic> calculateEntriesAndAmount(String category) {
    double total = 0.0;
    var list = _expenses.where((element) => element.category == category);
    for (final i in list) {
      total += i.amount;
    }
    return {'entries': list.length, 'totalAmount': total};
  }

  double calculateTotalExpenses() {
    return _categories.fold(
      0.0,
          (previousValue, element) => previousValue + element.totalAmount,
    );
  }

  List<Map<String, dynamic>> calculateWeekExpenses() {
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < 7; i++) {
      double total = 0.0;
      final weekDay = DateTime.now().subtract(Duration(days: i));

      for (int j = 0; j < _expenses.length; j++) {
        if (_expenses[j].date.year == weekDay.year &&
            _expenses[j].date.month == weekDay.month &&
            _expenses[j].date.day == weekDay.day) {
          total += _expenses[j].amount;
        }
      }

      data.add({'day': weekDay, 'amount': total});
    }
    return data;
  }

  Future<void> addIncome(Income income) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        iTable,
        income.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      ).then((generatedId) {
        final newIncome = Income(
          id: generatedId,
          title: income.title,
          amount: income.amount,
          date: income.date,
        );
        _incomes.add(newIncome);
        notifyListeners();
      });
    });
  }

  Future<void> deleteIncome(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(iTable, where: 'id == ?', whereArgs: [id]).then((_) {
        _incomes.removeWhere((income) => income.id == id);
        notifyListeners();
      });
    });
  }

  Future<void> fetchIncomes() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(iTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<Income> newList = List.generate(
          converted.length,
              (index) => Income.fromString(converted[index]),
        );
        _incomes = newList;
        return _incomes;
      });
    });
  }
}
