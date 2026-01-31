import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/recurring_expense.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos recurrentes')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          if (state.recurringExpenses.isEmpty) {
            return const Center(child: Text('Sin gastos recurrentes'));
          }
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final dateFormat = DateFormat('d MMM y', 'es');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.recurringExpenses.length,
            itemBuilder: (context, index) {
              final r = state.recurringExpenses[index];
              final cat = state.categoryById(r.categoryId);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (cat?.color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.2),
                    child: Icon(iconDataFromName(cat?.iconName ?? 'category'), color: cat?.color ?? Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(r.description.isEmpty ? 'Recurrente' : r.description),
                  subtitle: Text('${format.format(r.amount)} · ${r.frequency} · Próx: ${dateFormat.format(r.nextDate)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, state, r.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurring(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecurring(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String? categoryId = state.rootCategories.isNotEmpty ? state.rootCategories.first.id : null;
    String frequency = 'monthly';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nuevo gasto recurrente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 8),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: categoryId,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: state.rootCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => categoryId = v),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: frequency,
                  decoration: const InputDecoration(labelText: 'Frecuencia'),
                  items: const [DropdownMenuItem(value: 'weekly', child: Text('Semanal')), DropdownMenuItem(value: 'monthly', child: Text('Mensual'))],
                  onChanged: (v) => setState(() => frequency = v ?? 'monthly'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
                if (amount <= 0 || categoryId == null) return;
                var next = DateTime.now();
                if (frequency == 'weekly') next = next.add(const Duration(days: 7));
                else next = DateTime(next.year, next.month + 1, next.day);
                state.addRecurring(RecurringExpense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  amount: amount,
                  description: descController.text.trim(),
                  categoryId: categoryId!,
                  frequency: frequency,
                  nextDate: next,
                ));
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
        title: const Text('Eliminar recurrente'),
        content: const Text('¿Eliminar este gasto recurrente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () { state.removeRecurring(id); Navigator.pop(ctx); }, style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: const Text('Eliminar')),
        ],
      ),
    );
  }
}
