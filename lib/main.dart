import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'services/supabase_config.dart';
import 'screens/finance_shell.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
      'Run with --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
  SupabaseConfig.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  await initializeDateFormatting('es');
  runApp(const MisFinanzasApp());
}

class MisFinanzasApp extends StatelessWidget {
  const MisFinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: Selector<AppState, ({ThemeMode themeMode, Color accentColor})>(
        selector: (_, state) => (
          themeMode: state.themeMode,
          accentColor: state.accentColor,
        ),
        builder: (context, ui, _) {
          return MaterialApp(
            title: 'Mis Finanzas',
            debugShowCheckedModeBanner: false,
            themeMode: ui.themeMode,
            theme: buildAppTheme(
              brightness: Brightness.light,
              seedColor: ui.accentColor,
            ),
            darkTheme: buildAppTheme(
              brightness: Brightness.dark,
              seedColor: ui.accentColor,
            ),
            home: const FinanceShell(),
          );
        },
      ),
    );
  }
}
