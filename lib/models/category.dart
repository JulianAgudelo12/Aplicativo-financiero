import 'package:flutter/material.dart';

/// Categoría para clasificar gastos. parentId != null = subcategoría.
/// distributionType: 'fundamental' | 'fixed' | 'investment' | 'libre' para el gráfico de distribución.
class Category {
  final String id;
  final String name;
  final String iconName;
  final Color color;
  final String? parentId; // null = categoría raíz
  final String? distributionType; // para distribución: fundamental, fixed, investment, libre

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.parentId,
    this.distributionType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'color': color.toARGB32(),
        'parentId': parentId,
        'distributionType': distributionType,
      };

  static Category fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        iconName: json['iconName'] as String? ?? 'category',
        color: Color(json['color'] as int? ?? 0xFF2196F3),
        parentId: json['parentId'] as String?,
        distributionType: json['distributionType'] as String?,
      );

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    Color? color,
    String? parentId,
    String? distributionType,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        color: color ?? this.color,
        parentId: parentId ?? this.parentId,
        distributionType: distributionType ?? this.distributionType,
      );

  bool get isSubcategory => parentId != null && parentId!.isNotEmpty;
}

/// Categorías por defecto que se crean la primera vez (con tipo de distribución)
List<Category> get defaultCategories => [
      const Category(
        id: 'comida',
        name: 'Comida',
        iconName: 'restaurant',
        color: Color(0xFFE91E63),
        distributionType: 'fundamental',
      ),
      const Category(
        id: 'transporte',
        name: 'Transporte',
        iconName: 'directions_car',
        color: Color(0xFF9C27B0),
        distributionType: 'fundamental',
      ),
      const Category(
        id: 'hogar',
        name: 'Hogar',
        iconName: 'home',
        color: Color(0xFF3F51B5),
        distributionType: 'fundamental',
      ),
      const Category(
        id: 'entretenimiento',
        name: 'Entretenimiento',
        iconName: 'movie',
        color: Color(0xFF00BCD4),
        distributionType: 'libre',
      ),
      const Category(
        id: 'salud',
        name: 'Salud',
        iconName: 'local_hospital',
        color: Color(0xFF4CAF50),
        distributionType: 'fundamental',
      ),
      const Category(
        id: 'compras',
        name: 'Compras',
        iconName: 'shopping_cart',
        color: Color(0xFFFF9800),
        distributionType: 'libre',
      ),
      const Category(
        id: 'otros',
        name: 'Otros',
        iconName: 'category',
        color: Color(0xFF607D8B),
        distributionType: 'libre',
      ),
    ];

/// Categorías de ingreso por defecto (opcional).
List<Category> get defaultIncomeCategories => [
      const Category(
        id: 'sueldo',
        name: 'Sueldo',
        iconName: 'work',
        color: Color(0xFF4CAF50),
      ),
      const Category(
        id: 'freelance',
        name: 'Freelance',
        iconName: 'computer',
        color: Color(0xFF2196F3),
      ),
      const Category(
        id: 'ventas',
        name: 'Ventas',
        iconName: 'store',
        color: Color(0xFFFF9800),
      ),
      const Category(
        id: 'otros_ingreso',
        name: 'Otros ingresos',
        iconName: 'attach_money',
        color: Color(0xFF9E9E9E),
      ),
    ];
