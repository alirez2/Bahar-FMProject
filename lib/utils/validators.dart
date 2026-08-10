class Validators {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'لطفاً عنوان را وارد کنید';
    }
    if (value.trim().length < 2) {
      return 'عنوان باید حداقل ۲ کاراکتر باشد';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'لطفاً مبلغ را وارد کنید';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'مبلغ نامعتبر است';
    }
    if (amount <= 0) {
      return 'مبلغ باید بزرگتر از صفر باشد';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'لطفاً دسته‌بندی را انتخاب کنید';
    }
    return null;
  }

  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'لطفاً نام دسته‌بندی را وارد کنید';
    }
    if (value.trim().length < 2) {
      return 'نام باید حداقل ۲ کاراکتر باشد';
    }
    return null;
  }
}
