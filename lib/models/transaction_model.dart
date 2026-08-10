class TransactionModel {
  final String id;
  String title;
  double amount;
  String categoryId;
  DateTime date;
  String? description;
  bool isIncome;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.description,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'description': description,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      isIncome: (map['isIncome'] as int) == 1,
    );
  }
}
