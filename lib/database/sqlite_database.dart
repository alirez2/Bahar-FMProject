import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';

class SqliteDatabase {
  static Database? _database;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.categoriesTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        isIncome INTEGER NOT NULL,
        isDefault INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.transactionsTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        categoryId TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        isIncome INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES ${AppConstants.categoriesTable}(id)
      )
    ''');
  }

  // opr tr

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query(AppConstants.transactionsTable);
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<TransactionModel?> getTransaction(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert(
      AppConstants.transactionsTable,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.update(
      AppConstants.transactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionModel>> getRecentTransactions({int limit = 5}) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> searchTransactions(String query) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> filterByCategory(String categoryId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> filterByDate(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.transactionsTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        start.subtract(const Duration(days: 1)).toIso8601String(),
        end.add(const Duration(days: 1)).toIso8601String(),
      ],
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getCurrentMonthTransactions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return filterByDate(startOfMonth, endOfMonth);
  }

  // opr daste bandi

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final maps = await db.query(AppConstants.categoriesTable);
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<List<CategoryModel>> getIncomeCategories() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.categoriesTable,
      where: 'isIncome = ?',
      whereArgs: [1],
    );
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<List<CategoryModel>> getExpenseCategories() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.categoriesTable,
      where: 'isIncome = ?',
      whereArgs: [0],
    );
    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  Future<CategoryModel?> getCategory(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await database;
    await db.insert(
      AppConstants.categoriesTable,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await database;
    await db.update(
      AppConstants.categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<bool> deleteCategory(String id) async {
    final category = await getCategory(id);
    if (category == null || category.isDefault) return false;
    final db = await database;
    await db.delete(
      AppConstants.categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return true;
  }

  Future<void> initializeDefaultCategories() async {
    final existing = await getAllCategories();
    if (existing.isNotEmpty) return;

    for (final name in AppConstants.defaultIncomeCategories) {
      final category = CategoryModel(
        id: _uuid.v4(),
        name: name,
        isIncome: true,
        isDefault: true,
      );
      await addCategory(category);
    }

    for (final name in AppConstants.defaultExpenseCategories) {
      final category = CategoryModel(
        id: _uuid.v4(),
        name: name,
        isIncome: false,
        isDefault: true,
      );
      await addCategory(category);
    }
  }

  // const

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.transactionsTable} WHERE isIncome = 1",
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getTotalExpense() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.transactionsTable} WHERE isIncome = 0",
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getBalance() async {
    return (await getTotalIncome()) - (await getTotalExpense());
  }

  Future<double> getCurrentMonthIncome() async {
    final transactions = await getCurrentMonthTransactions();
    double total = 0;
    for (final t in transactions) {
      if (t.isIncome) total += t.amount;
    }
    return total;
  }

  Future<double> getCurrentMonthExpense() async {
    final transactions = await getCurrentMonthTransactions();
    double total = 0;
    for (final t in transactions) {
      if (!t.isIncome) total += t.amount;
    }
    return total;
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT c.name, COALESCE(SUM(t.amount), 0) as total
      FROM ${AppConstants.transactionsTable} t
      LEFT JOIN ${AppConstants.categoriesTable} c ON t.categoryId = c.id
      WHERE t.isIncome = 0
      GROUP BY t.categoryId
    ''');

    final map = <String, double>{};
    for (final row in result) {
      map[row['name'] as String? ?? 'نامشخص'] = (row['total'] as num)
          .toDouble();
    }
    return map;
  }

  Future<Map<String, Map<String, double>>> getMonthlyData({
    int months = 6,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final result = <String, Map<String, double>>{};

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      final monthKey = '${month.month}/${month.year}';

      final incomeResult = await db.rawQuery(
        "SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.transactionsTable} WHERE isIncome = 1 AND date >= ? AND date <= ?",
        [month.toIso8601String(), endOfMonth.toIso8601String()],
      );

      final expenseResult = await db.rawQuery(
        "SELECT COALESCE(SUM(amount), 0) as total FROM ${AppConstants.transactionsTable} WHERE isIncome = 0 AND date >= ? AND date <= ?",
        [month.toIso8601String(), endOfMonth.toIso8601String()],
      );

      result[monthKey] = {
        'income': (incomeResult.first['total'] as num).toDouble(),
        'expense': (expenseResult.first['total'] as num).toDouble(),
      };
    }

    return result;
  }

  // bkup

  Future<Map<String, dynamic>> exportData() async {
    final transactions = await getAllTransactions();
    final categories = await getAllCategories();

    return {
      'transactions': transactions
          .map(
            (t) => {
              'id': t.id,
              'title': t.title,
              'amount': t.amount,
              'categoryId': t.categoryId,
              'date': t.date.toIso8601String(),
              'description': t.description,
              'isIncome': t.isIncome,
            },
          )
          .toList(),
      'categories': categories
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'isIncome': c.isIncome,
              'isDefault': c.isDefault,
            },
          )
          .toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;

    await db.delete(AppConstants.transactionsTable);
    await db.delete(AppConstants.categoriesTable);

    final categories = data['categories'] as List;
    for (final cat in categories) {
      final category = CategoryModel(
        id: cat['id'],
        name: cat['name'],
        isIncome: cat['isIncome'],
        isDefault: cat['isDefault'],
      );
      await addCategory(category);
    }

    final transactions = data['transactions'] as List;
    for (final txn in transactions) {
      final transaction = TransactionModel(
        id: txn['id'],
        title: txn['title'],
        amount: (txn['amount'] as num).toDouble(),
        categoryId: txn['categoryId'],
        date: DateTime.parse(txn['date']),
        description: txn['description'],
        isIncome: txn['isIncome'],
      );
      await addTransaction(transaction);
    }
  }
}
