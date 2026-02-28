import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/savings_goal.dart';
import '../providers/app_state.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wishlist Goals',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Turn your planned purchases into trackable saving targets.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (state.goals.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.favorite_outline_rounded, size: 48, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 10),
                      Text('No wishlist items yet', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () => _showAddGoal(context, state),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                )
              else
                ...state.goals.map(
                  (goal) => _WishlistCard(
                    goal: goal,
                    progressLabel: '${format.format(goal.currentAmount)} / ${format.format(goal.targetAmount)}',
                    onAddFunds: () => _showAddToGoal(context, state, goal),
                  ),
                ),
            ],
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
        title: const Text('New Wishlist Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item name')),
            const SizedBox(height: 8),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(labelText: 'Target amount', prefixText: '\$ '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final target = double.tryParse(targetController.text.replaceAll(',', '.')) ?? 0;
              if (target <= 0) return;
              state.addGoal(
                SavingsGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim().isEmpty ? 'Wishlist item' : nameController.text.trim(),
                  targetAmount: target,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddToGoal(BuildContext context, AppState state, SavingsGoal goal) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add funds to ${goal.name}'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
              if (amount > 0) {
                state.updateGoal(goal.copyWith(currentAmount: goal.currentAmount + amount));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.goal,
    required this.progressLabel,
    required this.onAddFunds,
  });

  final SavingsGoal goal;
  final String progressLabel;
  final VoidCallback onAddFunds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
              color: const Color(0xFFEC4899).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.favorite_rounded, color: Color(0xFFEC4899)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                ),
                const SizedBox(height: 4),
                Text(progressLabel, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(onPressed: onAddFunds, icon: const Icon(Icons.add_rounded)),
        ],
      ),
    );
  }
}
