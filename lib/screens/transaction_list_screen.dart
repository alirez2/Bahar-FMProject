import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/reports_provider.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../widgets/transaction_item.dart';
import '../widgets/search_filter_bar.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لیست تراکنش‌ها')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // jostjoo v filter
              SearchFilterBar(
                onSearch: provider.search,
                onCategoryFilter: provider.filterByCategory,
                onDateFilter: provider.filterByDate,
                onClearFilters: provider.clearFilters,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.transactions.length} تراکنش',
                      style: const TextStyle(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // list tr
              Expanded(
                child: provider.transactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionList(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppConstants.textSecondaryColor,
          ),
          SizedBox(height: 16),
          Text(
            'تراکنشی یافت نشد',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    TransactionProvider provider,
  ) {
    return ListView.builder(
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = provider.transactions[index];
        return Dismissible(
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: AppConstants.expenseColor,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) => _confirmDelete(context),
          onDismissed: (direction) {
            provider.deleteTransaction(transaction.id);
            context.read<ReportsProvider>().loadReports();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تراکنش حذف شد'),
                backgroundColor: AppConstants.expenseColor,
              ),
            );
          },
          child: TransactionItem(
            transaction: transaction,
            onTap: () => _editTransaction(context, transaction),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف تراکنش'),
          content: const Text('آیا از حذف این تراکنش اطمینان دارید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.expenseColor,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(BuildContext context, TransactionModel transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }
}
