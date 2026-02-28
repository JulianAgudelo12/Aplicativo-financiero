import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_finanzas/providers/app_state.dart';
import 'package:mis_finanzas/screens/finance_shell.dart';
import 'package:provider/provider.dart';

import 'test_helpers/fake_app_state.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  testWidgets('App shell smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => FakeAppState(),
        child: const MaterialApp(home: FinanceShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FinanceApp'), findsWidgets);
  });
}
