/// Recordatorio in-app (sin notificaciones push).
class Reminder {
  final String id;
  final String title;
  final DateTime date;
  final bool done;

  const Reminder({
    required this.id,
    required this.title,
    required this.date,
    this.done = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'done': done,
      };

  static Reminder fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String,
        date: DateTime.parse(json['date'] as String),
        done: json['done'] as bool? ?? false,
      );

  Reminder copyWith({
    String? id,
    String? title,
    DateTime? date,
    bool? done,
  }) =>
      Reminder(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
        done: done ?? this.done,
      );
}
