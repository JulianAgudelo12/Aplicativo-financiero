/// Presupuesto por categoría para un mes (formato YYYY-MM).
class Budget {
  final String categoryId;
  final String month; // "2025-01"
  final double limit;

  const Budget({
    required this.categoryId,
    required this.month,
    required this.limit,
  });

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'month': month,
        'limit': limit,
      };

  static Budget fromJson(Map<String, dynamic> json) => Budget(
        categoryId: json['categoryId'] as String,
        month: json['month'] as String,
        limit: (json['limit'] as num).toDouble(),
      );
}
