/// Gasto recurrente (mensual, semanal, etc.).
class RecurringExpense {
  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final String frequency; // 'weekly', 'monthly'
  final DateTime nextDate;
  final String accountId;

  const RecurringExpense({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.frequency,
    required this.nextDate,
    this.accountId = 'default',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'categoryId': categoryId,
        'frequency': frequency,
        'nextDate': nextDate.toIso8601String(),
        'accountId': accountId,
      };

  static RecurringExpense fromJson(Map<String, dynamic> json) =>
      RecurringExpense(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String? ?? '',
        categoryId: json['categoryId'] as String,
        frequency: json['frequency'] as String? ?? 'monthly',
        nextDate: DateTime.parse(json['nextDate'] as String),
        accountId: json['accountId'] as String? ?? 'default',
      );

  RecurringExpense copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    String? frequency,
    DateTime? nextDate,
    String? accountId,
  }) =>
      RecurringExpense(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        frequency: frequency ?? this.frequency,
        nextDate: nextDate ?? this.nextDate,
        accountId: accountId ?? this.accountId,
      );
}
