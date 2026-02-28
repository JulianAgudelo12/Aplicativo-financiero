import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/debt.dart';
import '../models/distribution_target.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/investment.dart';
import '../models/period_filter.dart';
import '../models/recurring_expense.dart';
import '../models/reminder.dart';
import '../models/savings_goal.dart';
import '../models/tag.dart';
import '../models/transfer.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

const _keyThemeMode = 'themeMode';
const _keyAccentIndex = 'accentColorIndex';

/// Estado global: gastos, ingresos, cuentas, categorías, presupuestos, metas, etc.
class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  List<Category> _categories = [];
  List<Account> _accounts = [];
  List<Transfer> _transfers = [];
  List<Budget> _budgets = [];
  List<SavingsGoal> _goals = [];
  List<RecurringExpense> _recurring = [];
  List<Tag> _tags = [];
  List<Debt> _debts = [];
  List<Reminder> _reminders = [];
  List<Investment> _investments = [];
  bool _loaded = false;
  String? _profileId;
  DistributionTarget? _distributionTarget;

  int _themeModeIndex = 2;
  int _accentColorIndex = 0;

  // Filtro de período para dashboard
  PeriodFilter _dashboardPeriod = PeriodFilter.currentMonth();

  // Filtros para la lista de gastos
  String? _filterCategoryId;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  String _searchQuery = '';
  String? _filterAccountId;
  int _stateVersion = 0;
  int _dashboardCacheVersion = -1;
  _DashboardMetrics? _dashboardCache;
  _FilteredExpensesCache? _filteredExpensesCache;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Income> get incomes => List.unmodifiable(_incomes);
  List<Category> get categories => List.unmodifiable(_categories);
  List<Account> get accounts => List.unmodifiable(_accounts);
  List<Transfer> get transfers => List.unmodifiable(_transfers);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<SavingsGoal> get goals => List.unmodifiable(_goals);
  List<RecurringExpense> get recurringExpenses => List.unmodifiable(_recurring);
  List<Tag> get tags => List.unmodifiable(_tags);
  List<Debt> get debts => List.unmodifiable(_debts);
  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<Investment> get investments => List.unmodifiable(_investments);
  List<Investment> get activeInvestments => _investments.where((i) => i.isActive).toList();
  bool get loaded => _loaded;
  String? get profileId => _profileId;

  String? get filterCategoryId => _filterCategoryId;
  DateTime? get filterDateFrom => _filterDateFrom;
  DateTime? get filterDateTo => _filterDateTo;
  String get searchQuery => _searchQuery;
  String? get filterAccountId => _filterAccountId;

  // Período del dashboard
  PeriodFilter get dashboardPeriod => _dashboardPeriod;
  
  void setDashboardPeriod(PeriodFilter period) {
    _dashboardPeriod = period;
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_themeModeIndex) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  int get themeModeIndex => _themeModeIndex;
  int get accentColorIndex => _accentColorIndex;
  Color get accentColor =>
      accentColorOptions[_accentColorIndex.clamp(0, accentColorOptions.length - 1)];

  /// Gastos filtrados según categoría, fechas, búsqueda y cuenta.
  List<Expense> get filteredExpenses {
    final cache = _filteredExpensesCache;
    if (cache != null &&
        cache.stateVersion == _stateVersion &&
        cache.categoryId == _filterCategoryId &&
        cache.dateFrom == _filterDateFrom &&
        cache.dateTo == _filterDateTo &&
        cache.searchQuery == _searchQuery &&
        cache.accountId == _filterAccountId) {
      return cache.expenses;
    }

    var list = _expenses;
    if (_filterCategoryId != null) {
      list = list.where((e) => e.categoryId == _filterCategoryId).toList();
    }
    if (_filterDateFrom != null) {
      list = list.where((e) => !e.date.isBefore(_filterDateFrom!)).toList();
    }
    if (_filterDateTo != null) {
      final end = DateTime(_filterDateTo!.year, _filterDateTo!.month, _filterDateTo!.day, 23, 59, 59);
      list = list.where((e) => !e.date.isAfter(end)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) => e.description.toLowerCase().contains(q)).toList();
    }
    if (_filterAccountId != null) {
      list = list.where((e) => e.accountId == _filterAccountId).toList();
    }
    final result = List<Expense>.unmodifiable(list);
    _filteredExpensesCache = _FilteredExpensesCache(
      stateVersion: _stateVersion,
      categoryId: _filterCategoryId,
      dateFrom: _filterDateFrom,
      dateTo: _filterDateTo,
      searchQuery: _searchQuery,
      accountId: _filterAccountId,
      expenses: result,
    );
    return result;
  }

  void setFilterCategory(String? id) {
    _filterCategoryId = id;
    notifyListeners();
  }

  void setFilterDateRange(DateTime? from, DateTime? to) {
    _filterDateFrom = from;
    _filterDateTo = to;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterAccount(String? id) {
    _filterAccountId = id;
    notifyListeners();
  }

  void clearFilters() {
    _filterCategoryId = null;
    _filterDateFrom = null;
    _filterDateTo = null;
    _searchQuery = '';
    _filterAccountId = null;
    notifyListeners();
  }

  Future<void> load() async {
    if (_loaded) return;
    final profileId = await _storage.getProfileId();
    _profileId = profileId;

    final data = await Future.wait<Object?>([
      _storage.getExpenses(profileId: profileId),
      _storage.getCategories(profileId: profileId),
      _storage.getIncomes(profileId: profileId),
      _storage.getAccounts(profileId: profileId),
      _storage.getTransfers(profileId: profileId),
      _storage.getBudgets(profileId: profileId),
      _storage.getGoals(profileId: profileId),
      _storage.getRecurring(profileId: profileId),
      _storage.getTags(profileId: profileId),
      _storage.getDebts(profileId: profileId),
      _storage.getReminders(profileId: profileId),
      _storage.getInvestments(profileId: profileId),
      _storage.getDistributionTarget(profileId: profileId),
      _storage.getInt(_keyThemeMode),
      _storage.getInt(_keyAccentIndex),
    ]);

    _expenses = data[0] as List<Expense>;
    _categories = data[1] as List<Category>;
    _incomes = data[2] as List<Income>;
    _accounts = data[3] as List<Account>;
    _transfers = data[4] as List<Transfer>;
    _budgets = data[5] as List<Budget>;
    _goals = data[6] as List<SavingsGoal>;
    _recurring = data[7] as List<RecurringExpense>;
    _tags = data[8] as List<Tag>;
    _debts = data[9] as List<Debt>;
    _reminders = data[10] as List<Reminder>;
    _investments = data[11] as List<Investment>;
    _distributionTarget = data[12] as DistributionTarget?;
    _themeModeIndex = (data[13] as int?) ?? 2;
    _accentColorIndex = (data[14] as int?) ?? 0;
    _loaded = true;
    notifyListeners();
  }

  // --- Gastos ---
  Future<void> addExpense(Expense expense) async {
    _expenses = [..._expenses, expense]..sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveExpenses(_expenses, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    _expenses = _expenses.map((e) => e.id == expense.id ? expense : e).toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveExpenses(_expenses, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeExpense(String id) async {
    _expenses = _expenses.where((e) => e.id != id).toList();
    await _storage.saveExpenses(_expenses, profileId: _profileId);
    notifyListeners();
  }

  // --- Ingresos ---
  Future<void> addIncome(Income income) async {
    _incomes = [..._incomes, income]..sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveIncomes(_incomes, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateIncome(Income income) async {
    _incomes = _incomes.map((e) => e.id == income.id ? income : e).toList();
    _incomes.sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveIncomes(_incomes, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeIncome(String id) async {
    _incomes = _incomes.where((e) => e.id != id).toList();
    await _storage.saveIncomes(_incomes, profileId: _profileId);
    notifyListeners();
  }

  // --- Categorías ---
  Category? categoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Category> categoriesByParent(String? parentId) {
    return _categories.where((c) => c.parentId == parentId).toList();
  }

  List<Category> get rootCategories =>
      _categories.where((c) => c.parentId == null || c.parentId!.isEmpty).toList();

  Future<void> addCategory(Category category) async {
    if (_categories.any((c) => c.id == category.id)) return;
    _categories = [..._categories, category];
    await _storage.saveCategories(_categories, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    _categories = _categories.map((c) => c.id == category.id ? category : c).toList();
    await _storage.saveCategories(_categories, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeCategory(String id) async {
    _categories = _categories.where((c) => c.id != id).toList();
    await _storage.saveCategories(_categories, profileId: _profileId);
    notifyListeners();
  }

  // --- Cuentas ---
  Account? accountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  double accountBalance(String accountId) {
    final acc = accountById(accountId);
    if (acc == null) return 0;
    double balance = acc.initialBalance;
    for (final e in _expenses) {
      if (e.accountId == accountId) balance -= e.amount;
    }
    for (final i in _incomes) {
      if (i.accountId == accountId) balance += i.amount;
    }
    for (final t in _transfers) {
      if (t.fromAccountId == accountId) balance -= t.amount;
      if (t.toAccountId == accountId) balance += t.amount;
    }
    return balance;
  }

  Future<void> addAccount(Account account) async {
    if (_accounts.any((a) => a.id == account.id)) return;
    _accounts = [..._accounts, account];
    await _storage.saveAccounts(_accounts, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    _accounts = _accounts.map((a) => a.id == account.id ? account : a).toList();
    await _storage.saveAccounts(_accounts, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeAccount(String id) async {
    if (id == 'default') return;
    _accounts = _accounts.where((a) => a.id != id).toList();
    await _storage.saveAccounts(_accounts, profileId: _profileId);
    notifyListeners();
  }

  // --- Transferencias ---
  Future<void> addTransfer(Transfer transfer) async {
    _transfers = [..._transfers, transfer]..sort((a, b) => b.date.compareTo(a.date));
    await _storage.saveTransfers(_transfers, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeTransfer(String id) async {
    _transfers = _transfers.where((t) => t.id != id).toList();
    await _storage.saveTransfers(_transfers, profileId: _profileId);
    notifyListeners();
  }

  // --- Presupuestos ---
  double expenseTotalForCategoryMonth(String categoryId, String month) {
    return _expenses
        .where((e) {
          final m = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
          return e.categoryId == categoryId && m == month;
        })
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Budget? getBudget(String categoryId, String month) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId && b.month == month);
    } catch (_) {
      return null;
    }
  }

  Future<void> setBudget(Budget budget) async {
    _budgets = _budgets.where((b) => !(b.categoryId == budget.categoryId && b.month == budget.month)).toList();
    _budgets.add(budget);
    await _storage.saveBudgets(_budgets, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeBudget(String categoryId, String month) async {
    _budgets = _budgets.where((b) => b.categoryId != categoryId || b.month != month).toList();
    await _storage.saveBudgets(_budgets, profileId: _profileId);
    notifyListeners();
  }

  // --- Metas de ahorro ---
  Future<void> addGoal(SavingsGoal goal) async {
    _goals = [..._goals, goal];
    await _storage.saveGoals(_goals, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    _goals = _goals.map((g) => g.id == goal.id ? goal : g).toList();
    await _storage.saveGoals(_goals, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeGoal(String id) async {
    _goals = _goals.where((g) => g.id != id).toList();
    await _storage.saveGoals(_goals, profileId: _profileId);
    notifyListeners();
  }

  // --- Recurrentes ---
  Future<void> addRecurring(RecurringExpense r) async {
    _recurring = [..._recurring, r];
    await _storage.saveRecurring(_recurring, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateRecurring(RecurringExpense r) async {
    _recurring = _recurring.map((e) => e.id == r.id ? r : e).toList();
    await _storage.saveRecurring(_recurring, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeRecurring(String id) async {
    _recurring = _recurring.where((e) => e.id != id).toList();
    await _storage.saveRecurring(_recurring, profileId: _profileId);
    notifyListeners();
  }

  // --- Etiquetas ---
  Tag? tagById(String id) {
    try {
      return _tags.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTag(Tag tag) async {
    if (_tags.any((t) => t.id == tag.id)) return;
    _tags = [..._tags, tag];
    await _storage.saveTags(_tags, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateTag(Tag tag) async {
    _tags = _tags.map((t) => t.id == tag.id ? tag : t).toList();
    await _storage.saveTags(_tags, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeTag(String id) async {
    _tags = _tags.where((t) => t.id != id).toList();
    await _storage.saveTags(_tags, profileId: _profileId);
    notifyListeners();
  }

  // --- Deudas ---
  Future<void> addDebt(Debt debt) async {
    _debts = [..._debts, debt];
    await _storage.saveDebts(_debts, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateDebt(Debt debt) async {
    _debts = _debts.map((d) => d.id == debt.id ? debt : d).toList();
    await _storage.saveDebts(_debts, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeDebt(String id) async {
    _debts = _debts.where((d) => d.id != id).toList();
    await _storage.saveDebts(_debts, profileId: _profileId);
    notifyListeners();
  }

  // --- Recordatorios ---
  Future<void> addReminder(Reminder reminder) async {
    _reminders = [..._reminders, reminder]..sort((a, b) => a.date.compareTo(b.date));
    await _storage.saveReminders(_reminders, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder reminder) async {
    _reminders = _reminders.map((r) => r.id == reminder.id ? reminder : r).toList();
    _reminders.sort((a, b) => a.date.compareTo(b.date));
    await _storage.saveReminders(_reminders, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    _reminders = _reminders.where((r) => r.id != id).toList();
    await _storage.saveReminders(_reminders, profileId: _profileId);
    notifyListeners();
  }

  // --- Inversiones ---
  Investment? investmentById(String id) {
    try {
      return _investments.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addInvestment(Investment investment) async {
    _investments = [..._investments, investment];
    await _storage.saveInvestments(_investments, profileId: _profileId);
    notifyListeners();
  }

  Future<void> updateInvestment(Investment investment) async {
    _investments = _investments.map((i) => i.id == investment.id ? investment : i).toList();
    await _storage.saveInvestments(_investments, profileId: _profileId);
    notifyListeners();
  }

  Future<void> removeInvestment(String id) async {
    _investments = _investments.where((i) => i.id != id).toList();
    await _storage.saveInvestments(_investments, profileId: _profileId);
    notifyListeners();
  }

  /// Valor total de todas las inversiones activas
  double get totalInvestmentsValue => activeInvestments.fold(0.0, (sum, i) => sum + i.currentValue);

  /// Monto inicial total invertido (activas)
  double get totalInvestedAmount => activeInvestments.fold(0.0, (sum, i) => sum + i.initialAmount);

  /// Ganancia/pérdida total de inversiones
  double get totalInvestmentsReturn => totalInvestmentsValue - totalInvestedAmount;

  /// Porcentaje de retorno total de inversiones
  double get totalInvestmentsReturnPercent => 
      totalInvestedAmount > 0 ? (totalInvestmentsReturn / totalInvestedAmount) * 100 : 0;

  /// Valor proyectado de todas las inversiones a X meses
  double projectTotalInvestments(int months) {
    return activeInvestments.fold(0.0, (sum, investment) {
      final typeInfo = getInvestmentTypeInfo(investment.type);
      if (typeInfo.isFixedIncome && investment.fixedRate != null) {
        return sum + investment.projectFixedIncome(months);
      }
      return sum + investment.projectValue(months);
    });
  }

  // --- Totales ---
  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get totalIncomes => _incomes.fold(0.0, (sum, i) => sum + i.amount);
  double get balance => totalIncomes - totalExpenses;

  double totalExpensesInRange(DateTime from, DateTime to) {
    return _expenses
        .where((e) => !e.date.isBefore(from) && !e.date.isAfter(to))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double totalIncomesInRange(DateTime from, DateTime to) {
    return _incomes
        .where((i) => !i.date.isBefore(from) && !i.date.isAfter(to))
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  /// Gastos por categoría en un rango (para gráficos).
  Map<String, double> expensesByCategoryInRange(DateTime from, DateTime to) {
    final map = <String, double>{};
    for (final e in _expenses) {
      if (!e.date.isBefore(from) && !e.date.isAfter(to)) {
        map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
      }
    }
    return map;
  }

  // --- Métodos filtrados por período del dashboard ---
  
  /// Gastos en el período seleccionado del dashboard
  List<Expense> get periodExpenses {
    return _dashboardMetrics.periodExpenses;
  }

  /// Ingresos en el período seleccionado del dashboard
  List<Income> get periodIncomes {
    return _dashboardMetrics.periodIncomes;
  }

  /// Total de gastos en el período
  double get periodTotalExpenses => _dashboardMetrics.totalExpenses;

  /// Total de ingresos en el período
  double get periodTotalIncomes => _dashboardMetrics.totalIncomes;

  /// Balance en el período
  double get periodBalance => _dashboardMetrics.balance;

  /// Gastos por categoría en el período
  Map<String, double> get periodExpensesByCategory {
    return _dashboardMetrics.expensesByCategory;
  }

  /// Meta de distribución (porcentajes ideal). Si no hay guardada, devuelve la por defecto.
  DistributionTarget get distributionTarget =>
      _distributionTarget ?? const DistributionTarget();

  Future<void> setDistributionTarget(DistributionTarget target) async {
    _distributionTarget = target;
    await _storage.saveDistributionTarget(target, profileId: _profileId);
    notifyListeners();
  }

  /// Gastos agrupados por tipo de distribución en el período actual.
  Map<String, double> expensesByDistributionTypeInPeriod() {
    final map = <String, double>{
      kDistributionFundamental: 0,
      kDistributionFixed: 0,
      kDistributionInvestment: 0,
      kDistributionLibre: 0,
    };
    for (final e in periodExpenses) {
      final cat = categoryById(e.categoryId);
      final type = cat?.distributionType ?? kDistributionLibre;
      if (map.containsKey(type)) {
        map[type] = (map[type] ?? 0) + e.amount;
      } else {
        map[kDistributionLibre] = (map[kDistributionLibre] ?? 0) + e.amount;
      }
    }
    return map;
  }

  /// Porcentajes reales de distribución en el período respecto a los ingresos.
  Map<String, double> realityDistributionPercentagesInPeriod() {
    final byType = expensesByDistributionTypeInPeriod();
    final totalExp = periodTotalExpenses;
    final totalInc = periodTotalIncomes;
    final base = totalInc > 0 ? totalInc : (totalExp > 0 ? totalExp : 1.0);
    return {
      kDistributionFundamental:
          ((byType[kDistributionFundamental] ?? 0) / base * 100),
      kDistributionFixed: ((byType[kDistributionFixed] ?? 0) / base * 100),
      kDistributionInvestment:
          ((byType[kDistributionInvestment] ?? 0) / base * 100),
      kDistributionLibre: ((byType[kDistributionLibre] ?? 0) / base * 100),
    };
  }

  // Métodos legacy para compatibilidad
  Map<String, double> expensesByDistributionType() => expensesByDistributionTypeInPeriod();
  Map<String, double> realityDistributionPercentages() => realityDistributionPercentagesInPeriod();

  // --- Tema ---
  Future<void> setThemeMode(int index) async {
    _themeModeIndex = index.clamp(0, 2);
    await _storage.setInt(_keyThemeMode, _themeModeIndex);
    notifyListeners();
  }

  Future<void> setAccentColor(int index) async {
    _accentColorIndex = index.clamp(0, accentColorOptions.length - 1);
    await _storage.setInt(_keyAccentIndex, _accentColorIndex);
    notifyListeners();
  }

  // --- PIN ---
  Future<String?> getPinHash() => _storage.getPinHash();
  Future<void> setPinHash(String? hash) => _storage.setPinHash(hash);

  // --- Respaldo / Restauración ---
  Future<String> exportAllJson() => _storage.exportAllJson(profileId: _profileId);
  Future<void> importFromJson(String json) async {
    await _storage.importFromJson(json, profileId: _profileId);
    _loaded = false;
    await load();
  }

  _DashboardMetrics get _dashboardMetrics {
    if (_dashboardCache != null && _dashboardCacheVersion == _stateVersion) {
      return _dashboardCache!;
    }
    final (from, to) = _dashboardPeriod.getDateRange();

    final periodExpenses = _expenses
        .where((e) => !e.date.isBefore(from) && !e.date.isAfter(to))
        .toList(growable: false);
    final periodIncomes = _incomes
        .where((i) => !i.date.isBefore(from) && !i.date.isAfter(to))
        .toList(growable: false);

    final byCategory = <String, double>{};
    var totalExpenses = 0.0;
    for (final e in periodExpenses) {
      totalExpenses += e.amount;
      byCategory[e.categoryId] = (byCategory[e.categoryId] ?? 0) + e.amount;
    }

    var totalIncomes = 0.0;
    for (final i in periodIncomes) {
      totalIncomes += i.amount;
    }

    _dashboardCache = _DashboardMetrics(
      periodExpenses: List<Expense>.unmodifiable(periodExpenses),
      periodIncomes: List<Income>.unmodifiable(periodIncomes),
      totalExpenses: totalExpenses,
      totalIncomes: totalIncomes,
      balance: totalIncomes - totalExpenses,
      expensesByCategory: Map<String, double>.unmodifiable(byCategory),
    );
    _dashboardCacheVersion = _stateVersion;
    return _dashboardCache!;
  }

  @override
  void notifyListeners() {
    _stateVersion++;
    super.notifyListeners();
  }
}

class _DashboardMetrics {
  const _DashboardMetrics({
    required this.periodExpenses,
    required this.periodIncomes,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.balance,
    required this.expensesByCategory,
  });

  final List<Expense> periodExpenses;
  final List<Income> periodIncomes;
  final double totalExpenses;
  final double totalIncomes;
  final double balance;
  final Map<String, double> expensesByCategory;
}

class _FilteredExpensesCache {
  const _FilteredExpensesCache({
    required this.stateVersion,
    required this.categoryId,
    required this.dateFrom,
    required this.dateTo,
    required this.searchQuery,
    required this.accountId,
    required this.expenses,
  });

  final int stateVersion;
  final String? categoryId;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String searchQuery;
  final String? accountId;
  final List<Expense> expenses;
}
