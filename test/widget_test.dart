import 'package:flutter_test/flutter_test.dart';

import 'package:mis_finanzas/main.dart';

void main() {
  testWidgets('App muestra Mis Finanzas', (WidgetTester tester) async {
    await tester.pumpWidget(const MisFinanzasApp());
    await tester.pumpAndSettle();
    expect(find.text('Mis Finanzas'), findsWidgets);
  });
}
