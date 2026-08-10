import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/sqlite_database.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/reports_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = SqliteDatabase();
  await database.initializeDefaultCategories();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,

        locale: const Locale('fa', 'IR'),

        supportedLocales: const [Locale('fa', 'IR')],

        localizationsDelegates: const [
          PersianMaterialLocalizations.delegate,
          PersianCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
        ),

        home: const SplashScreen(),
      ),
    );
  }
}
