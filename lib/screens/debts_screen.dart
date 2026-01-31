import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/debt.dart';
import '../providers/app_state.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deudas')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          if (state.debts.isEmpty) {
            return const Center(child: Text('Sin deudas registradas'));
          }
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final dateFormat = DateFormat('d MMM y', 'es');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.debts.length,
            itemBuilder: (context, index) {
              final d = state.debts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(d.isOwed ? Icons.arrow_downward : Icons.arrow_upward, color: d.isOwed ? Colors.green : Theme.of(context).colorScheme.error),
                  title: Text(d.name),
                  subtitle: Text('Restante: ${format.format(d.remaining)}${d.dueDate != null ? ' · Vence: ${dateFormat.format(d.dueDate!)}' : ''}'),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, state, d.id)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebt(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDebt(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    bool isOwed = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nueva deuda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Persona o entidad')),
              const SizedBox(height: 8),
              TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 8),
              CheckboxListTile(title: const Text('Me deben (a mi favor)'), value: isOwed, onChanged: (v) => setState(() => isOwed = v ?? false)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
                if (amount <= 0 || nameController.text.trim().isEmpty) return;
                state.addDebt(Debt(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  amount: amount,
                  isOwed: isOwed,
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
        title: const Text('Eliminar deuda'),
        content: const Text('¿Eliminar este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () { state.removeDebt(id); Navigator.pop(ctx); }, style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: const Text('Eliminar')),
        ],
      ),
    );
  }
}
