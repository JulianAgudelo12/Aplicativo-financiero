import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const MisFinanzasApp());
}

class MisFinanzasApp extends StatelessWidget {
  const MisFinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: Consumer<AppState>(
        builder: (context, state, _) {
          return MaterialApp(
            title: 'Mis Finanzas',
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: buildAppTheme(
              brightness: Brightness.light,
              seedColor: state.accentColor,
            ),
            darkTheme: buildAppTheme(
              brightness: Brightness.dark,
              seedColor: state.accentColor,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
