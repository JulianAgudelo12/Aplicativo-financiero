/// Deuda o préstamo (a quién debo / quién me debe).
class Debt {
  final String id;
  final String name; // persona o entidad
  final double amount;
  final double paidAmount;
  final DateTime? dueDate;
  final bool isOwed; // true = me deben, false = debo
  final String? expenseId; // cuando se registra pago como gasto

  const Debt({
    required this.id,
    required this.name,
    required this.amount,
    this.paidAmount = 0,
    this.dueDate,
    this.isOwed = false,
    this.expenseId,
  });

  double get remaining => amount - paidAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'paidAmount': paidAmount,
        'dueDate': dueDate?.toIso8601String(),
        'isOwed': isOwed,
        'expenseId': expenseId,
      };

  static Debt fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
        dueDate: json['dueDate'] != null
            ? DateTime.parse(json['dueDate'] as String)
            : null,
        isOwed: json['isOwed'] as bool? ?? false,
        expenseId: json['expenseId'] as String?,
      );

  Debt copyWith({
    String? id,
    String? name,
    double? amount,
    double? paidAmount,
    DateTime? dueDate,
    bool? isOwed,
    String? expenseId,
  }) =>
      Debt(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        paidAmount: paidAmount ?? this.paidAmount,
        dueDate: dueDate ?? this.dueDate,
        isOwed: isOwed ?? this.isOwed,
        expenseId: expenseId ?? this.expenseId,
      );
}
