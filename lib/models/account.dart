/// Cuenta (efectivo, banco, billetera virtual).
class Account {
  final String id;
  final String name;
  final double initialBalance;
  final String currency;

  const Account({
    required this.id,
    required this.name,
    this.initialBalance = 0,
    this.currency = 'COP',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initialBalance': initialBalance,
        'currency': currency,
      };

  static Account fromJson(Map<String, dynamic> json) => Account(
        id: json['id'] as String,
        name: json['name'] as String,
        initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'COP',
      );

  Account copyWith({
    String? id,
    String? name,
    double? initialBalance,
    String? currency,
  }) =>
      Account(
        id: id ?? this.id,
        name: name ?? this.name,
        initialBalance: initialBalance ?? this.initialBalance,
        currency: currency ?? this.currency,
      );
}
