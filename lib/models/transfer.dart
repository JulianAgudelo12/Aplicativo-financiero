/// Transferencia entre cuentas (no es gasto ni ingreso).
class Transfer {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;
  final String note;

  const Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  static Transfer fromJson(Map<String, dynamic> json) => Transfer(
        id: json['id'] as String,
        fromAccountId: json['fromAccountId'] as String,
        toAccountId: json['toAccountId'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String? ?? '',
      );
}
