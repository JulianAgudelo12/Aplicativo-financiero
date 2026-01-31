import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/income.dart';
import '../providers/app_state.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  String? _accountId;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, AppState state) {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monto inválido')));
      return;
    }
    final income = Income(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      description: _descriptionController.text.trim(),
      accountId: _accountId ?? 'default',
      date: _date,
    );
    state.addIncome(income);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingreso agregado')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo ingreso')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          final accountId = _accountId ?? (state.accounts.isNotEmpty ? state.accounts.first.id : 'default');
          if (state.accounts.isNotEmpty && _accountId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _accountId = state.accounts.first.id);
            });
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                ),
                const SizedBox(height: 16),
                if (state.accounts.length > 1)
                  DropdownButtonFormField<String>(
                    value: accountId,
                    decoration: const InputDecoration(labelText: 'Cuenta'),
                    items: state.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (id) => setState(() => _accountId = id),
                  ),
                if (state.accounts.length > 1) const SizedBox(height: 16),
                ListTile(
                  title: Text('${_date.day}/${_date.month}/${_date.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (p != null) setState(() => _date = p);
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _submit(context, state),
                  child: const Text('Guardar ingreso'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
