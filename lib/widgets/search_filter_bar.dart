import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../providers/category_provider.dart';
import '../utils/constants.dart';

class SearchFilterBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(String?) onCategoryFilter;
  final Function(DateTime?, DateTime?) onDateFilter;
  final VoidCallback onClearFilters;

  const SearchFilterBar({
    super.key,
    required this.onSearch,
    required this.onCategoryFilter,
    required this.onDateFilter,
    required this.onClearFilters,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'جستجو در تراکنش‌ها...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppConstants.backgroundColor,
            ),
            onChanged: widget.onSearch,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildCategoryFilter()),
              const SizedBox(width: 8),
              _buildDateFilterButton(),
              const SizedBox(width: 8),
              _buildClearButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = Provider.of<CategoryProvider>(context).categories;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryId,
          hint: const Text('دسته‌بندی'),
          isExpanded: true,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('همه دسته‌بندی‌ها'),
            ),
            ...categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
            widget.onCategoryFilter(value);
          },
        ),
      ),
    );
  }

  Widget _buildDateFilterButton() {
    return InkWell(
      onTap: _showDateRangePicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 18),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.check,
                size: 16,
                color: AppConstants.incomeColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    final hasFilters =
        _selectedCategoryId != null ||
        _startDate != null ||
        _searchController.text.isNotEmpty;

    if (!hasFilters) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        setState(() {
          _searchController.clear();
          _selectedCategoryId = null;
          _startDate = null;
          _endDate = null;
        });
        widget.onClearFilters();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.expenseColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.filter_list_off,
          size: 18,
          color: AppConstants.expenseColor,
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final nowJalali = Jalali.now();

    final initialRange = _startDate != null && _endDate != null
        ? JalaliRange(
            start: Jalali.fromDateTime(_startDate!),
            end: Jalali.fromDateTime(_endDate!),
          )
        : null;

    final picked = await showPersianDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: Jalali(1390, 1, 1),
      lastDate: nowJalali,
      initialDate: initialRange?.start ?? nowJalali,
      initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
      locale: const Locale('fa', 'IR'),
      textDirection: TextDirection.rtl,
      helpText: 'انتخاب بازه تاریخ',
      cancelText: 'انصراف',
      confirmText: 'تأیید',
    );

    if (picked != null) {
      final start = picked.start.toDateTime();
      final end = picked.end.toDateTime();

      setState(() {
        _startDate = start;
        _endDate = end;
      });
      widget.onDateFilter(start, end);
    }
  }
}
