import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../database/sqlite_database.dart';

class CategoryProvider with ChangeNotifier {
  final SqliteDatabase _database = SqliteDatabase();
  List<CategoryModel> _categories = [];
  List<CategoryModel> _incomeCategories = [];
  List<CategoryModel> _expenseCategories = [];

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get incomeCategories => _incomeCategories;
  List<CategoryModel> get expenseCategories => _expenseCategories;

  void loadCategories() async {
    _categories = await _database.getAllCategories();
    _incomeCategories = await _database.getIncomeCategories();
    _expenseCategories = await _database.getExpenseCategories();
    notifyListeners();
  }

  String getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(id: '', name: 'نامشخص', isIncome: false),
    );
    return category.name;
  }

  bool canDelete(String id) {
    final category = _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => CategoryModel(id: '', name: '', isIncome: false),
    );
    return !category.isDefault;
  }

  Future<bool> addCategory(CategoryModel category) async {
    final exists = _categories.any(
      (c) => c.name == category.name && c.isIncome == category.isIncome,
    );
    if (exists) return false;

    await _database.addCategory(category);
    loadCategories();
    return true;
  }

  Future<bool> updateCategory(CategoryModel category) async {
    final exists = _categories.any(
      (c) =>
          c.id != category.id &&
          c.name == category.name &&
          c.isIncome == category.isIncome,
    );
    if (exists) return false;

    await _database.updateCategory(category);
    loadCategories();
    return true;
  }

  Future<bool> deleteCategory(String id) async {
    final result = await _database.deleteCategory(id);
    if (result) {
      loadCategories();
    }
    return result;
  }

  IconData getCategoryIcon(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(id: '', name: '', isIncome: false),
    );

    switch (category.name) {
      case 'خوراک':
        return Icons.lunch_dining;

      case 'حمل و نقل':
        return Icons.directions_car;

      case 'خرید':
        return Icons.shopping_bag;

      case 'قبوض':
        return Icons.receipt_long;

      case 'تفریح':
        return Icons.sports_esports;

      case 'سلامت و زیبایی':
        return Icons.self_improvement;

      case 'پوشاک':
        return Icons.checkroom;

      case 'قسط وام':
        return Icons.account_balance;

      case 'حقوق':
        return Icons.account_balance_wallet;
      case 'هدیه':
        return Icons.card_giftcard;

      default:
        return Icons.category;
    }
  }
}
