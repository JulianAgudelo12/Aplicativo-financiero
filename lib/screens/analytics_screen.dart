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
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          final byCategory = state.expensesByCategoryInRange(startOfMonth, endOfMonth);
          final totalExp = state.totalExpensesInRange(startOfMonth, endOfMonth);
          final totalInc = state.totalIncomesInRange(startOfMonth, endOfMonth);
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final monthName = DateFormat('MMMM y', 'es').format(now);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen $monthName', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Ingresos: ${format.format(totalInc)}'),
                      Text('Gastos: ${format.format(totalExp)}'),
                      Text('Balance: ${format.format(totalInc - totalExp)}', style: TextStyle(fontWeight: FontWeight.bold, color: (totalInc - totalExp) >= 0 ? Colors.green : Theme.of(context).colorScheme.error)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (byCategory.isNotEmpty) ...[
                Text('Gastos por categoría', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...byCategory.entries.map((e) {
                  final cat = state.categoryById(e.key);
                  final pct = totalExp > 0 ? (e.value / totalExp) : 0.0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (cat?.color ?? Theme.of(context).colorScheme.primary).withValues(alpha: 0.2),
                        child: Icon(iconDataFromName(cat?.iconName ?? 'category'), color: cat?.color ?? Theme.of(context).colorScheme.primary, size: 20),
                      ),
                      title: Text(cat?.name ?? e.key),
                      subtitle: LinearProgressIndicator(value: pct),
                      trailing: Text(format.format(e.value)),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _exportCsv(context, state),
                icon: const Icon(Icons.download),
                label: const Text('Exportar CSV'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _exportJson(context, state),
                icon: const Icon(Icons.backup),
                label: const Text('Exportar respaldo (JSON)'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, AppState state) async {
    final buffer = StringBuffer();
    buffer.writeln('Tipo,Fecha,Monto,Descripción,Categoría,Cuenta');
    for (final e in state.expenses) {
      final cat = state.categoryById(e.categoryId)?.name ?? e.categoryId;
      final acc = state.accountById(e.accountId)?.name ?? e.accountId;
      buffer.writeln('Gasto,${e.date.toIso8601String()},${e.amount},"${e.description.replaceAll('"', '""')}",$cat,$acc');
    }
    for (final i in state.incomes) {
      buffer.writeln('Ingreso,${i.date.toIso8601String()},${i.amount},"${i.description.replaceAll('"', '""')}",,${i.accountId}');
    }
    try {
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copiado al portapapeles')));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo copiar')));
    }
  }

  Future<void> _exportJson(BuildContext context, AppState state) async {
    try {
      final json = await state.exportAllJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respaldo JSON copiado al portapapeles')));
    } catch (_) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al exportar')));
    }
  }
}
