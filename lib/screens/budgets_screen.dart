import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/budget.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presupuestos')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          final now = DateTime.now();
          final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final budgets = state.budgets.where((b) => b.month == month).toList();
          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sin presupuestos este mes'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddBudget(context, state, month),
                    icon: const Icon(Icons.add),
                    label: const Text('Definir presupuesto'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final b = budgets[index];
              final cat = state.categoryById(b.categoryId);
              final spent = state.expenseTotalForCategoryMonth(b.categoryId, month);
              final pct = b.limit <= 0 ? 0.0 : (spent / b.limit).clamp(0.0, 2.0);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (cat != null)
                            Icon(iconDataFromName(cat.iconName), color: cat.color, size: 24),
                          const SizedBox(width: 8),
                          Text(cat?.name ?? b.categoryId, style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: pct > 1 ? 1 : pct,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pct > 1 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${format.format(spent)} / ${format.format(b.limit)}', style: Theme.of(context).textTheme.bodySmall),
                      if (pct > 1) Text('Excedido', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                    ],
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
          final now = DateTime.now();
          final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
          _showAddBudget(context, state, month);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudget(BuildContext context, AppState state, String month) {
    String? categoryId = state.rootCategories.isNotEmpty ? state.rootCategories.first.id : null;
    final limitController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nuevo presupuesto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: state.rootCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => categoryId = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: limitController,
                decoration: const InputDecoration(labelText: 'Límite mensual', prefixText: '\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (categoryId == null) return;
                final limit = double.tryParse(limitController.text.replaceAll(',', '.')) ?? 0;
                if (limit <= 0) return;
                state.setBudget(Budget(categoryId: categoryId!, month: month, limit: limit));
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
