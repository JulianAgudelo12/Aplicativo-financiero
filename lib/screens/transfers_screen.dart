import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transfer.dart';
import '../providers/app_state.dart';

class TransfersScreen extends StatelessWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transferencias')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          if (state.transfers.isEmpty) {
            return const Center(child: Text('Sin transferencias registradas'));
          }
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          final dateFormat = DateFormat('d MMM y', 'es');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.transfers.length,
            itemBuilder: (context, index) {
              final t = state.transfers[index];
              final from = state.accountById(t.fromAccountId)?.name ?? t.fromAccountId;
              final to = state.accountById(t.toAccountId)?.name ?? t.toAccountId;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
                  title: Text('$from → $to'),
                  subtitle: Text('${dateFormat.format(t.date)} · ${format.format(t.amount)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, state, t.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransfer(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransfer(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    if (state.accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Necesitas al menos 2 cuentas')));
      return;
    }
    String? fromId = state.accounts.first.id;
    String? toId = state.accounts.length > 1 ? state.accounts[1].id : null;
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva transferencia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: fromId,
                  decoration: const InputDecoration(labelText: 'Desde'),
                  items: state.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v) => setDialogState(() => fromId = v),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: toId,
                  decoration: const InputDecoration(labelText: 'Hacia'),
                  items: state.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (v) => setDialogState(() => toId = v),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (fromId == null || toId == null || fromId == toId) return;
                final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
                if (amount <= 0) return;
                state.addTransfer(Transfer(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  fromAccountId: fromId!,
                  toAccountId: toId!,
                  amount: amount,
                  date: DateTime.now(),
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
        title: const Text('Eliminar transferencia'),
        content: const Text('¿Eliminar esta transferencia?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              state.removeTransfer(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
