/// Ingreso registrado por el usuario.
class Income {
  final String id;
  final double amount;
  final String description;
  final String? categoryId; // opcional: Sueldo, Freelance, etc.
  final String accountId;
  final DateTime date;
  final String currency;

  const Income({
    required this.id,
    required this.amount,
    required this.description,
    this.categoryId,
    required this.accountId,
    required this.date,
    this.currency = 'COP',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'categoryId': categoryId,
        'accountId': accountId,
        'date': date.toIso8601String(),
        'currency': currency,
      };

  static Income fromJson(Map<String, dynamic> json) => Income(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String? ?? '',
        categoryId: json['categoryId'] as String?,
        accountId: json['accountId'] as String? ?? 'default',
        date: DateTime.parse(json['date'] as String),
        currency: json['currency'] as String? ?? 'COP',
      );

  Income copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    String? accountId,
    DateTime? date,
    String? currency,
  }) =>
      Income(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        accountId: accountId ?? this.accountId,
        date: date ?? this.date,
        currency: currency ?? this.currency,
      );
}
