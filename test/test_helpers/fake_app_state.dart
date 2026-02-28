import 'package:mis_finanzas/models/category.dart';
import 'package:mis_finanzas/models/expense.dart';
import 'package:mis_finanzas/models/period_filter.dart';
import 'package:mis_finanzas/providers/app_state.dart';

class FakeAppState extends AppState {
  FakeAppState({
    this.income = 8000000,
    this.expense = 3100000,
    this.balanceValue = 4900000,
    List<Expense>? expenses,
    Map<String, double>? byCategory,
    this.categoryMap = const {},
  })  : expensesList = expenses ??
            [
              Expense(
                id: 'e1',
                amount: 120000,
                description: 'Groceries',
                categoryId: 'food',
                date: DateTime(2026, 2, 10),
              ),
            ],
        byCategory = byCategory ?? const {'food': 120000};

  final double income;
  final double expense;
  final double balanceValue;
  final List<Expense> expensesList;
  final Map<String, double> byCategory;
  final Map<String, Category> categoryMap;

  @override
  bool get loaded => true;

  @override
  double get periodTotalIncomes => income;

  @override
  double get periodTotalExpenses => expense;

  @override
  double get periodBalance => balanceValue;

  @override
  List<Expense> get periodExpenses => expensesList;

  @override
  Map<String, double> get periodExpensesByCategory => byCategory;

  @override
  Category? categoryById(String id) => categoryMap[id];

  @override
  PeriodFilter get dashboardPeriod => PeriodFilter.currentMonth();
}
