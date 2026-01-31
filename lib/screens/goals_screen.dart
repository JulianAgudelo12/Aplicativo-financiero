import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/savings_goal.dart';
import '../providers/app_state.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas de ahorro')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          if (state.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sin metas definidas'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddGoal(context, state),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear meta'),
                  ),
                ],
              ),
            );
          }
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.goals.length,
            itemBuilder: (context, index) {
              final g = state.goals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.savings, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(g.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(value: g.progress),
                      Text('${format.format(g.currentAmount)} / ${format.format(g.targetAmount)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddToGoal(context, state, g),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final state = Provider.of<AppState>(context, listen: false);
          _showAddGoal(context, state);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoal(BuildContext context, AppState state) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre (ej: Vacaciones)')),
            const SizedBox(height: 8),
            TextField(controller: targetController, decoration: const InputDecoration(labelText: 'Objetivo', prefixText: '\$ '), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final target = double.tryParse(targetController.text.replaceAll(',', '.')) ?? 0;
              if (target <= 0) return;
              state.addGoal(SavingsGoal(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim().isEmpty ? 'Meta' : nameController.text.trim(),
                targetAmount: target,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showAddToGoal(BuildContext context, AppState state, SavingsGoal g) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sumar a ${g.name}'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
              if (amount > 0) {
                state.updateGoal(g.copyWith(currentAmount: g.currentAmount + amount));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Sumar'),
          ),
        ],
      ),
    );
  }
}
