import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/distribution_target.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) return const Center(child: CircularProgressIndicator());
          final categories = state.rootCategories.isEmpty ? state.categories : state.rootCategories;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final c = categories[index];
              final subCount = state.categoriesByParent(c.id).length;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.color.withValues(alpha: 0.2),
                    child: Icon(iconDataFromName(c.iconName), color: c.color),
                  ),
                  title: Text(c.name),
                  subtitle: subCount > 0 ? Text('$subCount subcategorías') : null,
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                    onSelected: (v) {
                      if (v == 'edit') _showEditCategory(context, state, c);
                      if (v == 'delete') _confirmDelete(context, state, c.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategory(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategory(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final nameController = TextEditingController();
    String selectedType = kDistributionLibre;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nueva categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo para distribución',
                ),
                items: distributionTypeKeys
                    .map((key) => DropdownMenuItem(
                          value: key,
                          child: Text(distributionTypeLabel(key)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v ?? kDistributionLibre),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
                state.addCategory(Category(
                  id: id,
                  name: nameController.text.trim(),
                  iconName: 'category',
                  color: const Color(0xFF607D8B),
                  distributionType: selectedType,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategory(BuildContext context, AppState state, Category c) {
    final nameController = TextEditingController(text: c.name);
    String selectedType = c.distributionType ?? kDistributionLibre;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Editar categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: distributionTypeKeys.contains(selectedType)
                    ? selectedType
                    : kDistributionLibre,
                decoration: const InputDecoration(
                  labelText: 'Tipo para distribución',
                ),
                items: distributionTypeKeys
                    .map((key) => DropdownMenuItem(
                          value: key,
                          child: Text(distributionTypeLabel(key)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v ?? kDistributionLibre),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                state.updateCategory(c.copyWith(
                  name: nameController.text.trim(),
                  distributionType: selectedType,
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
        title: const Text('Eliminar categoría'),
        content: const Text('¿Eliminar esta categoría? Los gastos quedarán sin categoría.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              state.removeCategory(id);
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
