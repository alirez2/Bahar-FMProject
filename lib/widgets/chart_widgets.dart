import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

/// wig nemoodar dayere
class ExpensePieChart extends StatelessWidget {
  final Map<String, double> data;

  const ExpensePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'داده‌ای برای نمایش وجود ندارد',
          style: TextStyle(color: AppConstants.textSecondaryColor),
        ),
      );
    }

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    final entries = data.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (index) {
                final entry = entries[index];
                final percentage = (entry.value / total * 100);
                return PieChartSectionData(
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  color: AppConstants
                      .chartColors[index % AppConstants.chartColors.length],
                  radius: 80,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: List.generate(entries.length, (index) {
            final entry = entries[index];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppConstants
                        .chartColors[index % AppConstants.chartColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(entry.key, style: const TextStyle(fontSize: 12)),
              ],
            );
          }),
        ),
      ],
    );
  }
}

/// wig nemoodar mile
class MonthlyBarChart extends StatelessWidget {
  final Map<String, Map<String, double>> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'داده‌ای برای نمایش وجود ندارد',
          style: TextStyle(color: AppConstants.textSecondaryColor),
        ),
      );
    }

    final entries = data.entries.toList();
    final maxY = _getMaxValue();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < entries.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            entries[index].key,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatValue(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: List.generate(entries.length, (index) {
                final entry = entries[index];
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value['income'] ?? 0,
                      color: AppConstants.incomeColor,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: entry.value['expense'] ?? 0,
                      color: AppConstants.expenseColor,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend('درآمد', AppConstants.incomeColor),
            const SizedBox(width: 24),
            _buildLegend('هزینه', AppConstants.expenseColor),
          ],
        ),
      ],
    );
  }

  double _getMaxValue() {
    double max = 0;
    for (final entry in data.entries) {
      final income = entry.value['income'] ?? 0;
      final expense = entry.value['expense'] ?? 0;
      if (income > max) max = income;
      if (expense > max) max = expense;
    }
    return max;
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
