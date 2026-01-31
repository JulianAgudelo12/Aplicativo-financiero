import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/app_state.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          if (state.reminders.isEmpty) {
            return const Center(child: Text('Sin recordatorios'));
          }
          final dateFormat = DateFormat('d MMM y HH:mm', 'es');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reminders.length,
            itemBuilder: (context, index) {
              final r = state.reminders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(r.done ? Icons.check_circle : Icons.notifications_none, color: r.done ? Colors.grey : Theme.of(context).colorScheme.primary),
                  title: Text(r.title, style: TextStyle(decoration: r.done ? TextDecoration.lineThrough : null)),
                  subtitle: Text(dateFormat.format(r.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(r.done ? Icons.undo : Icons.check), onPressed: () => state.updateReminder(r.copyWith(done: !r.done))),
                      IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, state, r.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminder(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddReminder(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final titleController = TextEditingController();
    DateTime date = DateTime.now();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nuevo recordatorio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
              const SizedBox(height: 8),
              ListTile(
                title: Text('${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d != null) setState(() => date = DateTime(d.year, d.month, d.day, date.hour, date.minute));
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                state.addReminder(Reminder(id: DateTime.now().millisecondsSinceEpoch.toString(), title: titleController.text.trim(), date: date));
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: const Text('¿Eliminar este recordatorio?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () { state.removeReminder(id); Navigator.pop(ctx); }, style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: const Text('Eliminar')),
        ],
      ),
    );
  }
}
