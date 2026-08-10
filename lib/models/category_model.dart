class CategoryModel {
  final String id;
  String name;
  final bool isIncome;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.isIncome,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isIncome': isIncome ? 1 : 0,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isIncome: (map['isIncome'] as int) == 1,
      isDefault: (map['isDefault'] as int) == 1,
    );
  }
}
