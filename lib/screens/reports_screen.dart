import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reports_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/chart_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش‌')),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              provider.loadReports();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthlySummaryCard(provider),
                  const SizedBox(height: 24),
                  _buildSectionTitle('هزینه‌ها بر اساس دسته‌بندی'),
                  const SizedBox(height: 12),
                  _buildPieChartCard(provider),
                  const SizedBox(height: 24),
                  _buildSectionTitle('درآمد و هزینه ماهانه'),
                  const SizedBox(height: 12),
                  _buildBarChartCard(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// c kholase mah jari
  Widget _buildMonthlySummaryCard(ReportsProvider provider) {
    return Card(
      color: AppConstants.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'خلاصه ماه جاری',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'درآمد',
              Formatters.formatCurrency(provider.monthlyIncome),
              AppConstants.incomeColor,
              Icons.arrow_downward,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'هزینه',
              Formatters.formatCurrency(provider.monthlyExpense),
              AppConstants.expenseColor,
              Icons.arrow_upward,
            ),
            const Divider(),
            _buildSummaryRow(
              'موجودی',
              Formatters.formatCurrency(provider.balance),
              provider.balance >= 0
                  ? AppConstants.incomeColor
                  : AppConstants.expenseColor,
              Icons.account_balance_wallet,
            ),
          ],
        ),
      ),
    );
  }

  /// kholase
  Widget _buildSummaryRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppConstants.textSecondaryColor),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  /// nemodar dayere
  Widget _buildPieChartCard(ReportsProvider provider) {
    return Card(
      color: AppConstants.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (provider.expensesByCategory.isEmpty)
              const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'هنوز هزینه‌ای ثبت نشده است',
                    style: TextStyle(color: AppConstants.textSecondaryColor),
                  ),
                ),
              )
            else
              ExpensePieChart(data: provider.expensesByCategory),
          ],
        ),
      ),
    );
  }
  

  /// nemoodar mile
  Widget _buildBarChartCard(ReportsProvider provider) {
    return Card(
      color: AppConstants.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (provider.monthlyData.isEmpty)
              const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'داده‌ای برای نمایش وجود ندارد',
                    style: TextStyle(color: AppConstants.textSecondaryColor),
                  ),
                ),
              )
            else
              MonthlyBarChart(data: provider.monthlyData),
          ],
        ),
      ),
    );
  }
}
