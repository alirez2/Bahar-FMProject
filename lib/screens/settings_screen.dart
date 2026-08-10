import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/backup_service.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/reports_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('بک‌آپ گیری'),
          _buildSettingsTile(
            icon: Icons.backup,
            title: 'ایجاد بک‌آپ',
            subtitle: 'ذخیره داده‌ها در فایل',
            onTap: () => _createBackup(context),
          ),
          _buildSettingsTile(
            icon: Icons.restore,
            title: 'بازیابی بک‌آپ',
            subtitle: 'بازگردانی داده‌ها از فایل',
            onTap: () => _showRestoreDialog(context),
          ),
          const Divider(),
          _buildSectionHeader('درباره'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'درباره برنامه',
            subtitle: 'نسخه و اطلاعات برنامه',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// bkup
  Future<void> _createBackup(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ایجاد بک‌آپ'),
          content: const Text('آیا می‌خواهید بک‌آپ تهیه کنید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('بله'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final backupService = BackupService();
    final path = await backupService.createBackup();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            path != null ? 'بک‌آپ با موفقیت ایجاد شد' : 'خطا در ایجاد بک‌آپ',
          ),
          backgroundColor: path != null
              ? AppConstants.incomeColor
              : AppConstants.expenseColor,
        ),
      );
    }
  }

  /// dialog restore
  Future<void> _showRestoreDialog(BuildContext context) async {
    final backupService = BackupService();
    final files = await backupService.getBackupFiles();

    if (!context.mounted) return;

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فایل بک‌آپی یافت نشد'),
          backgroundColor: AppConstants.expenseColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('انتخاب فایل بک‌آپ'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final fileName = file.path.split('\\').last;
                final modified = File(file.path).statSync().modified;
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(fileName),
                  subtitle: Text(Formatters.formatDateTime(modified)),
                  onTap: () {
                    Navigator.pop(context);
                    _restoreBackup(context, file.path);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
          ],
        );
      },
    );
  }

  /// restore
  Future<void> _restoreBackup(BuildContext context, String filePath) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('بازیابی بک‌آپ'),
          content: const Text(
            'توجه: با بازیابی، تمام داده‌های فعلی جایگزین خواهند شد.\nآیا ادامه می‌دهید؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.expenseColor,
              ),
              child: const Text('بازیابی'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final backupService = BackupService();
    final success = await backupService.restoreBackup(filePath);

    if (success && context.mounted) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
      context.read<ReportsProvider>().loadReports();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'بازیابی با موفقیت انجام شد' : 'خطا در بازیابی',
          ),
          backgroundColor: success
              ? AppConstants.incomeColor
              : AppConstants.expenseColor,
        ),
      );
    }
  }
}
