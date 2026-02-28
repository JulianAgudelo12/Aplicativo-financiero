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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Budget')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final budgets = state.budgets.where((b) => b.month == month).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Budget Planner',
                      style: TextStyle(
                        color: Color(0xFF0A0E1A),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track category limits and overspending in real time.',
                      style: TextStyle(color: Color(0xFF0A0E1A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (budgets.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.pie_chart_outline_rounded, size: 48, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 10),
                      Text('No budgets set for this month', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () => _showAddBudget(context, state, month),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Budget'),
                      ),
                    ],
                  ),
                )
              else
                ...budgets.map((b) {
                  final cat = state.categoryById(b.categoryId);
                  final spent = state.expenseTotalForCategoryMonth(b.categoryId, month);
                  final pct = b.limit <= 0 ? 0.0 : (spent / b.limit).clamp(0.0, 2.0);
                  final overLimit = pct > 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: (cat?.color ?? scheme.primary).withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                iconDataFromName(cat?.iconName ?? 'category'),
                                color: cat?.color ?? scheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(cat?.name ?? b.categoryId, style: Theme.of(context).textTheme.titleMedium),
                            ),
                            if (overLimit)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: scheme.error.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Over limit',
                                  style: TextStyle(
                                    color: scheme.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: overLimit ? 1 : pct,
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            overLimit ? scheme.error : const Color(0xFF00D9FF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${format.format(spent)} / ${format.format(b.limit)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }),
            ],
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
          title: const Text('Create Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: state.rootCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => categoryId = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: limitController,
                decoration: const InputDecoration(labelText: 'Monthly Limit', prefixText: '\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (categoryId == null) return;
                final limit = double.tryParse(limitController.text.replaceAll(',', '.')) ?? 0;
                if (limit <= 0) return;
                state.setBudget(Budget(categoryId: categoryId!, month: month, limit: limit));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
