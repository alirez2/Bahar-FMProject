import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('درباره برنامه')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(64, 0, 58, 92),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'پولکی',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'نسخه ${AppConstants.appVersion}',
                style: const TextStyle(color: AppConstants.textSecondaryColor),
              ),
              const SizedBox(height: 32),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'پولکی؛ برنامه مدیریت مالی شخصی',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'امکانات:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ثبت درآمد و هزینه\n'
                        'مدیریت دسته‌بندی‌ها\n'
                        'جستجو و فیلتر تراکنش‌ها\n'
                        'نمودارهای آماری\n'
                        'پشتیبان‌گیری و بازیابی',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'ساخته شده با فلاتر',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'پروژه پایان کارشناسی\n'
                  'سید علیرضا موسوی',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
