import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          final byCategory = state.expensesByCategoryInRange(startOfMonth, endOfMonth);
          final totalExp = state.totalExpensesInRange(startOfMonth, endOfMonth);
          final totalInc = state.totalIncomesInRange(startOfMonth, endOfMonth);
          final balance = totalInc - totalExp;
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final monthName = DateFormat('MMMM y', 'en').format(now);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Report • $monthName',
                      style: const TextStyle(
                        color: Color(0xFF0A0E1A),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track your month performance and export data snapshots.',
                      style: TextStyle(color: Color(0xFF0A0E1A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _MetricRow(
                title: 'Income',
                value: format.format(totalInc),
                color: const Color(0xFF10B981),
              ),
              _MetricRow(
                title: 'Expenses',
                value: format.format(totalExp),
                color: const Color(0xFFEF4444),
              ),
              _MetricRow(
                title: 'Balance',
                value: format.format(balance),
                color: balance >= 0 ? const Color(0xFF00D9FF) : const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 10),
              if (byCategory.isNotEmpty) ...[
                Text('Expense Breakdown', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                ...byCategory.entries.map((entry) {
                  final cat = state.categoryById(entry.key);
                  final pct = totalExp > 0 ? (entry.value / totalExp) : 0.0;
                  final color = cat?.color ?? scheme.primary;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.2),
                          child: Icon(iconDataFromName(cat?.iconName ?? 'category'), color: color, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat?.name ?? entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(6),
                                backgroundColor: scheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(format.format(entry.value)),
                      ],
                    ),
                  );
                }),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Text('No category spend recorded this month', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _exportCsv(context, state),
                icon: const Icon(Icons.download),
                label: const Text('Export CSV'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _exportJson(context, state),
                icon: const Icon(Icons.backup),
                label: const Text('Export JSON Backup'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, AppState state) async {
    final buffer = StringBuffer();
    buffer.writeln('Type,Date,Amount,Description,Category,Account');
    for (final e in state.expenses) {
      final cat = state.categoryById(e.categoryId)?.name ?? e.categoryId;
      final acc = state.accountById(e.accountId)?.name ?? e.accountId;
      buffer.writeln(
        'Expense,${e.date.toIso8601String()},${e.amount},"${e.description.replaceAll('"', '""')}",$cat,$acc',
      );
    }
    for (final i in state.incomes) {
      buffer.writeln(
        'Income,${i.date.toIso8601String()},${i.amount},"${i.description.replaceAll('"', '""')}",,${i.accountId}',
      );
    }
    try {
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not copy CSV')));
      }
    }
  }

  Future<void> _exportJson(BuildContext context, AppState state) async {
    try {
      final json = await state.exportAllJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON backup copied')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export failed')));
      }
    }
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(value),
        ],
      ),
    );
  }
}
