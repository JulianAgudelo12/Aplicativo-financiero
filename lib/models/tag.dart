import 'package:flutter/material.dart';

/// Etiqueta para clasificar gastos además de la categoría.
class Tag {
  final String id;
  final String name;
  final Color color;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
      };

  static Tag fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        name: json['name'] as String,
        color: Color(json['color'] as int? ?? 0xFF757575),
      );
}
