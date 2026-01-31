import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Apariencia',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tema',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 0, icon: Icon(Icons.light_mode), label: Text('Claro')),
                              ButtonSegment(value: 1, icon: Icon(Icons.dark_mode), label: Text('Oscuro')),
                              ButtonSegment(value: 2, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
                            ],
                            selected: {state.themeModeIndex},
                            onSelectionChanged: (s) {
                              final v = s.first;
                              state.setThemeMode(v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Color de acento'),
                      subtitle: const Text('Elige el color principal de la app'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          accentColorOptions.length,
                          (i) => GestureDetector(
                            onTap: () => state.setAccentColor(i),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accentColorOptions[i],
                                shape: BoxShape.circle,
                                border: state.accentColorIndex == i
                                    ? Border.all(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        width: 3,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Seguridad y datos',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('PIN de bloqueo'),
                  subtitle: const Text('Protege la app con PIN (próximamente)'),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN disponible en una próxima versión')),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Exportar respaldo'),
                  subtitle: const Text('Copiar todos los datos como JSON'),
                  onTap: () async {
                    final json = await state.exportAllJson();
                    await Clipboard.setData(ClipboardData(text: json));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Respaldo copiado al portapapeles')),
                      );
                    }
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restaurar respaldo'),
                  subtitle: const Text('Pegar JSON para restaurar (reemplaza datos)'),
                  onTap: () => _showImportDialog(context, state),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Acerca de',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text('Mis Finanzas'),
                  subtitle: const Text(
                    'Organiza gastos, ingresos, cuentas, presupuestos y más. Web y PWA.',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImportDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar respaldo'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Pega aquí el JSON del respaldo',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              try {
                jsonDecode(text);
                await state.importFromJson(text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Datos restaurados')),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('JSON inválido')),
                  );
                }
              }
            },
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}
