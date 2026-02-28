import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mis_finanzas/models/category.dart';
import 'package:mis_finanzas/models/expense.dart';
import 'package:mis_finanzas/providers/app_state.dart';
import 'package:mis_finanzas/screens/home_screen.dart';
import 'package:provider/provider.dart';

import '../test_helpers/fake_app_state.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  Future<void> pumpHome(WidgetTester tester, FakeAppState state) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: Scaffold(body: HomeScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders 4 KPI cards with expected labels and values', (tester) async {
    final fakeState = FakeAppState(
      income: 10000000,
      expense: 4000000,
      balanceValue: 6000000,
      expenses: [
        Expense(
          id: '1',
          amount: 400000,
          description: 'Rent',
          categoryId: 'housing',
          date: DateTime.utc(2026, 2, 5),
        ),
      ],
      byCategory: const {'housing': 400000},
      categoryMap: const {
        'housing': Category(
          id: 'housing',
          name: 'Housing',
          iconName: 'home',
          color: Color(0xFF3B82F6),
        ),
      },
    );

    await pumpHome(tester, fakeState);

    expect(find.text('Total Income'), findsOneWidget);
    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('Net Balance'), findsOneWidget);
    expect(find.text('Savings Rate'), findsOneWidget);
    expect(find.text('60.0%'), findsOneWidget);
  });

  testWidgets('handles empty expenses state', (tester) async {
    final fakeState = FakeAppState(
      income: 0,
      expense: 0,
      balanceValue: 0,
      expenses: const [],
      byCategory: const {},
    );

    await pumpHome(tester, fakeState);

    expect(find.text('No expense data available'), findsOneWidget);
  });
}
