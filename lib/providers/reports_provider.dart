import 'package:flutter/material.dart';
import '../database/sqlite_database.dart';

class ReportsProvider with ChangeNotifier {
  final SqliteDatabase _database = SqliteDatabase();

  double _monthlyIncome = 0;
  double _monthlyExpense = 0;
  double _balance = 0;
  Map<String, double> _expensesByCategory = {};
  Map<String, Map<String, double>> _monthlyData = {};

  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  double get balance => _balance;
  Map<String, double> get expensesByCategory => _expensesByCategory;
  Map<String, Map<String, double>> get monthlyData => _monthlyData;

  void loadReports() async {
    _monthlyIncome = await _database.getCurrentMonthIncome();
    _monthlyExpense = await _database.getCurrentMonthExpense();
    _balance = await _database.getBalance();
    _expensesByCategory = await _database.getExpensesByCategory();
    _monthlyData = await _database.getMonthlyData();
    notifyListeners();
  }
}
