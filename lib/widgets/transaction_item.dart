import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categoryName = categoryProvider.getCategoryName(
      transaction.categoryId,
    );
    final isIncome = transaction.isIncome;

    return Card(
      color: AppConstants.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isIncome
              ? AppConstants.incomeColor.withValues(alpha: 0.12)
              : AppConstants.expenseColor.withValues(alpha: 0.12),
          child: Icon(
            categoryProvider.getCategoryIcon(transaction.categoryId),
            size: 24,
            color: isIncome
                ? AppConstants.incomeColor
                : AppConstants.expenseColor,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '$categoryName • ${Formatters.formatDate(transaction.date)}',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'} ${Formatters.formatAmount(transaction.amount)}',
              style: TextStyle(
                color: isIncome
                    ? AppConstants.incomeColor
                    : AppConstants.expenseColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'تومان',
              style: TextStyle(
                fontSize: 10,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
