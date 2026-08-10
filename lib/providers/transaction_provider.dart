import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../database/sqlite_database.dart';

class TransactionProvider with ChangeNotifier {
  final SqliteDatabase _database = SqliteDatabase();
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  List<TransactionModel> _recentTransactions = [];
  String _searchQuery = '';
  String? _filterCategoryId;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;

  List<TransactionModel> get transactions => _filteredTransactions;
  List<TransactionModel> get allTransactions => _transactions;
  List<TransactionModel> get recentTransactions => _recentTransactions;
  String get searchQuery => _searchQuery;
  String? get filterCategoryId => _filterCategoryId;
  double get balance => _balance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;

  void loadTransactions() async {
    _transactions = await _database.getAllTransactions();
    _recentTransactions = await _database.getRecentTransactions();
    _totalIncome = await _database.getTotalIncome();
    _totalExpense = await _database.getTotalExpense();
    _balance = _totalIncome - _totalExpense;
    _applyFilters();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _database.addTransaction(transaction);
    loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _database.updateTransaction(transaction);
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _database.deleteTransaction(id);
    loadTransactions();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(String? categoryId) {
    _filterCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void filterByDate(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategoryId = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTransactions = List.from(_transactions);

    if (_searchQuery.isNotEmpty) {
      _filteredTransactions = _filteredTransactions
          .where((t) => t.title.contains(_searchQuery))
          .toList();
    }

    if (_filterCategoryId != null) {
      _filteredTransactions = _filteredTransactions
          .where((t) => t.categoryId == _filterCategoryId)
          .toList();
    }

    if (_filterStartDate != null && _filterEndDate != null) {
      _filteredTransactions = _filteredTransactions
          .where(
            (t) =>
                t.date.isAfter(
                  _filterStartDate!.subtract(const Duration(days: 1)),
                ) &&
                t.date.isBefore(_filterEndDate!.add(const Duration(days: 1))),
          )
          .toList();
    }

    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
  }
}
