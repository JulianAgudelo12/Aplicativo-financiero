import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_finanzas/providers/app_state.dart';
import 'package:mis_finanzas/screens/app_section.dart';
import 'package:mis_finanzas/screens/finance_shell.dart';
import 'package:provider/provider.dart';

import '../test_helpers/fake_app_state.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  Future<void> pumpShell(
    WidgetTester tester, {
    required Size size,
    AppSection initialSection = AppSection.dashboard,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => FakeAppState(),
        child: MaterialApp(home: FinanceShell(initialSection: initialSection)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('desktop renders sidebar and dashboard content', (tester) async {
    await pumpShell(tester, size: const Size(1280, 900));

    expect(find.text('Personal Finance Manager'), findsOneWidget);
    expect(find.text('Financial Dashboard'), findsOneWidget);
  });

  testWidgets('mobile renders bottom nav and switches sections', (tester) async {
    await pumpShell(
      tester,
      size: const Size(800, 844),
      initialSection: AppSection.transactions,
    );

    expect(find.text('Transactions'), findsWidgets);
    await tester.tap(find.text(AppSection.debts.label).first);
    await tester.pumpAndSettle();

    expect(find.text('Debts'), findsWidgets);
  });
}
