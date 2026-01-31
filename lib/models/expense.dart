/// Un gasto registrado por el usuario, con monto, descripción, categoría y fecha.
class Expense {
  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final DateTime date;
  final String accountId;
  final List<String> tagIds;
  final String currency;
  final String? attachmentBase64; // comprobante en base64 (opcional, tamaño limitado)

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
    this.accountId = 'default',
    this.tagIds = const [],
    this.currency = 'COP',
    this.attachmentBase64,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'accountId': accountId,
        'tagIds': tagIds,
        'currency': currency,
        'attachmentBase64': attachmentBase64,
      };

  static Expense fromJson(Map<String, dynamic> json) {
    final tagIdsRaw = json['tagIds'];
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      accountId: json['accountId'] as String? ?? 'default',
      tagIds: tagIdsRaw is List
          ? (tagIdsRaw).map((e) => e.toString()).toList()
          : [],
      currency: json['currency'] as String? ?? 'COP',
      attachmentBase64: json['attachmentBase64'] as String?,
    );
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    DateTime? date,
    String? accountId,
    List<String>? tagIds,
    String? currency,
    String? attachmentBase64,
  }) =>
      Expense(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        accountId: accountId ?? this.accountId,
        tagIds: tagIds ?? this.tagIds,
        currency: currency ?? this.currency,
        attachmentBase64: attachmentBase64 ?? this.attachmentBase64,
      );
}
