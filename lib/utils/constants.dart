import 'package:flutter/material.dart';

class AppConstants {
  static const String databaseName = 'poolaki.db';
  static const String transactionsTable = 'transactions';
  static const String categoriesTable = 'categories';
  static const String appName = 'پولکی';
  static const String appVersion = '1.0.0';

  static const List<String> defaultIncomeCategories = [
    'حقوق',
    'قرض و وام',
    'هدیه',
    'سایر',
  ];

  static const List<String> defaultExpenseCategories = [
    'خوراک',
    'حمل و نقل',
    'خرید',
    'قبوض',
    'تفریح',
    'سلامت و زیبایی',
    'پوشاک',
    'قسط وام',
    'سایر',
  ];
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color.fromARGB(255, 240, 153, 30), Color.fromARGB(255, 0, 58, 92)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const Color primaryColor = Color.fromARGB(255, 0, 58, 92);
  static const Color incomeColor = Color.fromARGB(255, 9, 72, 109);
  static const Color expenseColor = Color.fromARGB(255, 240, 153, 30);
  static const Color backgroundColor = Color(0xFFF8FEFF);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color.fromARGB(255, 4, 4, 4);
  static const Color textSecondaryColor = Color.fromARGB(255, 66, 66, 66);

  static const List<Color> chartColors = [
    Color(0xFF009688),
    Color(0xFFFF9800),
    Color(0xFF3F51B5),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFFF5722),
    Color(0xFFFF5765),
    Color(0xFF607D8B),
  ];
}
