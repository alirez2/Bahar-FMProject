import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter/services.dart';

class Formatters {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount.toInt())} تومان';
  }

  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount.toInt());
  }

  static String formatDate(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.formatter.yyyy}/${j.formatter.mm}/${j.formatter.dd}';
  }

  static String formatDateTime(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.formatter.yyyy}/${j.formatter.mm}/${j.formatter.dd} - ${DateFormat('HH:mm').format(date)}';
  }

  static String getMonthName(int month) {
    const months = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];
    return months[month - 1];
  }

  static String formatMonthYear(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${getMonthName(j.month)} ${j.year}';
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String value = newValue.text.replaceAll(',', '');

    if (value.isEmpty) {
      return const TextEditingValue();
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return oldValue;
    }

    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
