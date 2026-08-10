import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مدیریت دسته‌بندی‌ها'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'درآمد'),
              Tab(text: 'هزینه'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CategoryList(isIncome: true),
            _CategoryList(isIncome: false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCategoryDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddCategoryDialog(),
    );
  }
}

/// list daste
class _CategoryList extends StatelessWidget {
  final bool isIncome;

  const _CategoryList({required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final categories = isIncome
            ? provider.incomeCategories
            : provider.expenseCategories;

        if (categories.isEmpty) {
          return const Center(child: Text('دسته‌بندی‌ای وجود ندارد'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryItem(category: category);
          },
        );
      },
    );
  }
}

/// item daste
class _CategoryItem extends StatelessWidget {
  final CategoryModel category;

  const _CategoryItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.isIncome
              ? AppConstants.incomeColor.withValues(alpha: 0.1)
              : AppConstants.expenseColor.withValues(alpha: 0.1),
          child: Icon(
            category.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: category.isIncome
                ? AppConstants.incomeColor
                : AppConstants.expenseColor,
          ),
        ),
        title: Text(category.name),
        subtitle: Text(
          category.isDefault ? 'پیش‌فرض' : 'سفارشی',
          style: TextStyle(
            color: category.isDefault
                ? AppConstants.textSecondaryColor
                : AppConstants.primaryColor,
          ),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('ویرایش'),
                ],
              ),
            ),
            if (!category.isDefault)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: 20,
                      color: AppConstants.expenseColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'حذف',
                      style: TextStyle(color: AppConstants.expenseColor),
                    ),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(context);
            } else if (value == 'delete') {
              _confirmDelete(context);
            }
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EditCategoryDialog(category: category),
    );
  }

  /// hazf
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف دسته‌بندی'),
          content: Text('آیا از حذف "${category.name}" اطمینان دارید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () async {
                final provider = Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                );
                final success = await provider.deleteCategory(category.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'دسته‌بندی حذف شد'
                            : 'امکان حذف دسته‌بندی پیش‌فرض وجود ندارد',
                      ),
                      backgroundColor: success
                          ? AppConstants.incomeColor
                          : AppConstants.expenseColor,
                    ),
                  );
                }
              },
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
}

/// add
class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isIncome = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('افزودن دسته‌بندی'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'نام دسته‌بندی',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateCategoryName,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            // entekhab type
            Row(
              children: [
                const Text('نوع: '),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('هزینه'),
                  selected: !_isIncome,
                  onSelected: (selected) {
                    if (selected) setState(() => _isIncome = false);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('درآمد'),
                  selected: _isIncome,
                  onSelected: (selected) {
                    if (selected) setState(() => _isIncome = true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('ذخیره')),
      ],
    );
  }

  /// savew
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = CategoryModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      isIncome: _isIncome,
      isDefault: false,
    );

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.addCategory(category);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'دسته‌بندی با موفقیت افزوده شد'
                : 'این نام قبلاً استفاده شده است',
          ),
          backgroundColor: success
              ? AppConstants.incomeColor
              : AppConstants.expenseColor,
        ),
      );
    }
  }
}

class _EditCategoryDialog extends StatefulWidget {
  final CategoryModel category;

  const _EditCategoryDialog({required this.category});

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ویرایش دسته‌بندی'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'نام دسته‌بندی',
            border: OutlineInputBorder(),
          ),
          validator: Validators.validateCategoryName,
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('انصراف'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('ذخیره')),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    widget.category.name = _nameController.text.trim();

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.updateCategory(widget.category);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'دسته‌بندی ویرایش شد' : 'این نام قبلاً استفاده شده است',
          ),
          backgroundColor: success
              ? AppConstants.incomeColor
              : AppConstants.expenseColor,
        ),
      );
    }
  }
}
