import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/account.dart' as models;
import '../providers/app_state.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.accounts.length,
            itemBuilder: (context, index) {
              final a = state.accounts[index];
              final balance = state.accountBalance(a.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(a.name),
                  subtitle: Text('Saldo: ${format.format(balance)}'),
                  trailing: a.id != 'default'
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context, state, a.id),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccount(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccount(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva cuenta'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre (ej: Banco, Efectivo)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final state = Provider.of<AppState>(context, listen: false);
              final id = 'acc_${DateTime.now().millisecondsSinceEpoch}';
              state.addAccount(models.Account(id: id, name: nameController.text.trim().isEmpty ? 'Cuenta' : nameController.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('¿Eliminar esta cuenta? Los movimientos no se borran.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              state.removeAccount(id);
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
