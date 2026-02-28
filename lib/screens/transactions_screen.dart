import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/app_state.dart';
import 'add_expense_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y', 'en');
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = [...state.periodExpenses]..sort((a, b) => b.date.compareTo(a.date));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transactions',
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Recent expense activity in selected period',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions in this period',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final category = state.categoryById(expense.categoryId);
                        return _TransactionTile(
                          expense: expense,
                          categoryName: category?.name ?? 'Uncategorized',
                          categoryColor: category?.color ?? scheme.primary,
                          amountText: format.format(expense.amount),
                          dateText: dateFormat.format(expense.date),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.expense,
    required this.categoryName,
    required this.categoryColor,
    required this.amountText,
    required this.dateText,
  });

  final Expense expense;
  final String categoryName;
  final Color categoryColor;
  final String amountText;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: categoryColor.withValues(alpha: 0.18),
            ),
            child: Icon(Icons.receipt_long_rounded, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description.isEmpty ? 'Expense' : expense.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$categoryName • $dateText',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountText,
            style: TextStyle(
              color: scheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
