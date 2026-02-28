import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/debt.dart';
import '../providers/app_state.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Debts')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final dateFormat = DateFormat('d MMM y', 'en');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Debt Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track what you owe and what others owe you.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (state.debts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card_off_rounded, size: 48, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 10),
                      Text('No debts registered', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                )
              else
                ...state.debts.map((debt) {
                  return _DebtCard(
                    debt: debt,
                    amountText: format.format(debt.remaining),
                    dueDateText: debt.dueDate == null ? null : dateFormat.format(debt.dueDate!),
                    onDelete: () => _confirmDelete(context, state, debt.id),
                  );
                }),
            ],
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
          title: const Text('New Debt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Person or entity')),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('They owe me'),
                value: isOwed,
                onChanged: (v) => setState(() => isOwed = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
                if (amount <= 0 || nameController.text.trim().isEmpty) return;
                state.addDebt(
                  Debt(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    amount: amount,
                    isOwed: isOwed,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
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
        title: const Text('Delete debt'),
        content: const Text('Delete this debt record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              state.removeDebt(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({
    required this.debt,
    required this.amountText,
    required this.onDelete,
    this.dueDateText,
  });

  final Debt debt;
  final String amountText;
  final String? dueDateText;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = debt.isOwed ? const Color(0xFF10B981) : scheme.error;
    final subtitle = dueDateText == null ? amountText : '$amountText • Due $dueDateText';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              debt.isOwed ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(debt.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: onDelete),
        ],
      ),
    );
  }
}
