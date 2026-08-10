import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/reports_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isIncome = false;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;

    if (_isEditing) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = Formatters.formatAmount(
        widget.transaction!.amount,
      );
      _descriptionController.text = widget.transaction!.description ?? '';
      _isIncome = widget.transaction!.isIncome;
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedDate = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش تراکنش' : 'افزودن تراکنش'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTransactionTypeSelector(),
              const SizedBox(height: 24),

              _buildTitleField(),
              const SizedBox(height: 16),

              _buildAmountField(),
              const SizedBox(height: 16),

              _buildCategorySelector(),
              const SizedBox(height: 16),

              _buildDateSelector(),
              const SizedBox(height: 16),

              _buildDescriptionField(),
              const SizedBox(height: 32),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// entekhab type tr
  Widget _buildTransactionTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // dokme hazine
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isIncome = false;
                  _selectedCategoryId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: !_isIncome
                      ? AppConstants.expenseColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'هزینه',
                    style: TextStyle(
                      color: !_isIncome
                          ? Colors.white
                          : AppConstants.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // dokme daramad
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isIncome = true;
                  _selectedCategoryId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isIncome
                      ? AppConstants.incomeColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'درآمد',
                    style: TextStyle(
                      color: _isIncome
                          ? Colors.white
                          : AppConstants.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// title
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'عنوان',
        hintText: 'عنوان هزینه یا درآمد را وارد کنید',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: Validators.validateTitle,
      textInputAction: TextInputAction.next,
    );
  }

  /// mablagh
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'مبلغ (تومان)',
        hintText: 'مثال: ۵۰,۰۰۰',
        prefixIcon: const Icon(Icons.monetization_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [ThousandsSeparatorInputFormatter()],
      validator: Validators.validateAmount,
      textInputAction: TextInputAction.next,
    );
  }

  /// entekhabgar daste
  Widget _buildCategorySelector() {
    final categories = _isIncome
        ? context.watch<CategoryProvider>().incomeCategories
        : context.watch<CategoryProvider>().expenseCategories;

    final selectedCategory = categories.where(
      (e) => e.id == _selectedCategoryId,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return Container(
              height: MediaQuery.of(context).size.height * .55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'انتخاب دسته‌بندی',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (_, index) {
                        final category = categories[index];
                        final selected = category.id == _selectedCategoryId;

                        return ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppConstants.primaryColor
                                .withValues(alpha: 0.1),
                            child: Icon(
                              context.read<CategoryProvider>().getCategoryIcon(
                                category.id,
                              ),
                              color: AppConstants.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(category.name),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppConstants.primaryColor,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(context, category.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );

        if (result != null) {
          setState(() {
            _selectedCategoryId = result;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'دسته‌بندی',
          prefixIcon: const Icon(Icons.category),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          selectedCategory.isEmpty
              ? 'انتخاب دسته بندی'
              : selectedCategory.first.name,
          style: TextStyle(
            color: selectedCategory.isEmpty
                ? Colors.grey.shade600
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  ///sakht entekhab tarikh
  Widget _buildDateSelector() {
    return InkWell(
      onTap: _showDatePicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'تاریخ',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          '${Jalali.fromDateTime(_selectedDate).year}/${Jalali.fromDateTime(_selectedDate).month.toString().padLeft(2, '0')}/${Jalali.fromDateTime(_selectedDate).day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  /// ghesmat tozihat
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'توضیحات',
        hintText: 'توضیحات اضافی...',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
    );
  }

  /// dokme save
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        _isEditing ? 'ویرایش تراکنش' : 'ذخیره تراکنش',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  /// namayes entekhab tarikh
  Future<void> _showDatePicker() async {
    final nowJalali = Jalali.now();
    final selectedJalali = Jalali.fromDateTime(_selectedDate);

    final picked = await showPersianDatePicker(
      context: context,
      initialDate: selectedJalali,
      firstDate: Jalali(1390, 1, 1),
      lastDate: nowJalali,
      initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
      initialDatePickerMode: PersianDatePickerMode.day,
      locale: const Locale('fa', 'IR'),
      textDirection: TextDirection.rtl,
      helpText: 'انتخاب تاریخ',
      cancelText: 'انصراف',
      confirmText: 'تأیید',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked.toDateTime();
      });
    }
  }

  /// save tr
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.replaceAll(',', ''));

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً دسته‌بندی را انتخاب کنید')),
      );
      return;
    }

    if (_isEditing) {
      // virayesh tr
      final updatedTransaction = TransactionModel(
        id: widget.transaction!.id,
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isIncome: _isIncome,
      );

      await context.read<TransactionProvider>().updateTransaction(
        updatedTransaction,
      );
    } else {
      // afzoodan tr
      final newTransaction = TransactionModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isIncome: _isIncome,
      );

      await context.read<TransactionProvider>().addTransaction(newTransaction);
    }

    if (mounted) {
      // update gozaresh
      context.read<ReportsProvider>().loadReports();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'تراکنش ویرایش شد' : 'تراکنش ثبت شد'),
          backgroundColor: AppConstants.incomeColor,
        ),
      );
    }
  }
}
