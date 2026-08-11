import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/reports_provider.dart';
import '../utils/constants.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';
import 'transaction_list_screen.dart';
import 'categories_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // bargozari data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
      context.read<ReportsProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const TransactionListScreen();
      case 2:
        return const ReportsScreen();
      case 3:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  /// sakht mohtavaye safhe
  Widget _buildHomeContent() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            provider.loadTransactions();
            context.read<ReportsProvider>().loadReports();
          },
          child: CustomScrollView(
            slivers: [
              // navar bala
              SliverAppBar(
                expandedHeight: 60,
                floating: true,
                pinned: true,
                title: const Text(
                  AppConstants.appName,
                  style: TextStyle(fontSize: 18),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.category),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // cart mojjodi
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BalanceCard(
                    balance: provider.balance,
                    totalIncome: provider.totalIncome,
                    totalExpense: provider.totalExpense,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'تراکنش‌های اخیر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                        child: const Text('مشاهده همه و ویرایش'),
                      ),
                    ],
                  ),
                ),
              ),
              // list tr ahir
              if (provider.recentTransactions.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: AppConstants.textSecondaryColor,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'تراکنشی ثبت نشده است',
                            style: TextStyle(
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final transaction = provider.recentTransactions[index];
                    return TransactionItem(
                      transaction: transaction,
                      onTap: () => _showTransactionDetails(transaction),
                    );
                  }, childCount: provider.recentTransactions.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }

  /// navar paein
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'خانه'),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'تراکنش‌ها',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'گزارش‌'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'تنظیمات'),
      ],
    );
  }

  /// dokme afzoodan
  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: AppConstants.primaryColor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        );
      },
      child: const Icon(Icons.add, color: Color.fromARGB(255, 255, 149, 0)),
    );
  }

  /// namayesh detail tr
  void _showTransactionDetails(TransactionModel transaction) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final categoryName = categoryProvider.getCategoryName(
      transaction.categoryId,
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                transaction.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                'مبلغ',
                transaction.isIncome
                    ? '+ ${transaction.amount.toStringAsFixed(0)} تومان'
                    : '- ${transaction.amount.toStringAsFixed(0)} تومان',
                transaction.isIncome
                    ? AppConstants.incomeColor
                    : AppConstants.expenseColor,
              ),
              _buildDetailRow(
                'نوع',
                transaction.isIncome ? 'درآمد' : 'هزینه',
                null,
              ),
              _buildDetailRow('دسته‌بندی', categoryName, null),
              _buildDetailRow(
                'تاریخ',
                Formatters.formatDate(transaction.date),
                null,
              ),
              if (transaction.description != null &&
                  transaction.description!.isNotEmpty)
                _buildDetailRow('توضیحات', transaction.description!, null),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, Color? valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppConstants.textSecondaryColor),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
          ),
        ],
      ),
    );
  }
}
