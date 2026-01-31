import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/debt.dart';
import '../models/distribution_target.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/investment.dart';
import '../models/recurring_expense.dart';
import '../models/reminder.dart';
import '../models/savings_goal.dart';
import '../models/tag.dart';
import '../models/transfer.dart';

const _keyExpenses = 'expenses';
const _keyDistributionTarget = 'distributionTarget';
const _keyInvestments = 'investments';
const _keyCategories = 'categories';
const _keyIncomes = 'incomes';
const _keyAccounts = 'accounts';
const _keyTransfers = 'transfers';
const _keyBudgets = 'budgets';
const _keyGoals = 'savings_goals';
const _keyRecurring = 'recurring_expenses';
const _keyTags = 'tags';
const _keyDebts = 'debts';
const _keyReminders = 'reminders';
const _keyPinHash = 'pinHash';
const _keyProfileId = 'profileId';
const _keyCurrencyRates = 'currencyRates';

/// Guarda y carga todos los datos en el dispositivo (web: localStorage).
class StorageService {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _store async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _prefix(String? profileId) =>
      profileId != null && profileId.isNotEmpty ? '${profileId}_' : '';

  Future<List<Expense>> getExpenses({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyExpenses);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveExpenses(List<Expense> expenses, {String? profileId}) async {
    final store = await _store;
    final list = expenses.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyExpenses, jsonEncode(list));
  }

  Future<List<Category>> getCategories({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyCategories);
    if (raw == null) return defaultCategories;
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null || list.isEmpty) return defaultCategories;
    return list
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<Category> categories,
      {String? profileId}) async {
    final store = await _store;
    final list = categories.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyCategories, jsonEncode(list));
  }

  Future<List<Income>> getIncomes({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyIncomes);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Income.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveIncomes(List<Income> incomes, {String? profileId}) async {
    final store = await _store;
    final list = incomes.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyIncomes, jsonEncode(list));
  }

  Future<List<Account>> getAccounts({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyAccounts);
    if (raw == null) return [const Account(id: 'default', name: 'Principal')];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null || list.isEmpty) {
      return [const Account(id: 'default', name: 'Principal')];
    }
    return list
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAccounts(List<Account> accounts,
      {String? profileId}) async {
    final store = await _store;
    final list = accounts.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyAccounts, jsonEncode(list));
  }

  Future<List<Transfer>> getTransfers({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyTransfers);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Transfer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTransfers(List<Transfer> transfers,
      {String? profileId}) async {
    final store = await _store;
    final list = transfers.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyTransfers, jsonEncode(list));
  }

  Future<List<Budget>> getBudgets({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyBudgets);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Budget.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveBudgets(List<Budget> budgets, {String? profileId}) async {
    final store = await _store;
    final list = budgets.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyBudgets, jsonEncode(list));
  }

  Future<List<SavingsGoal>> getGoals({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyGoals);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => SavingsGoal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveGoals(List<SavingsGoal> goals, {String? profileId}) async {
    final store = await _store;
    final list = goals.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyGoals, jsonEncode(list));
  }

  Future<List<RecurringExpense>> getRecurring({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyRecurring);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => RecurringExpense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecurring(List<RecurringExpense> list,
      {String? profileId}) async {
    final store = await _store;
    final data = list.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyRecurring, jsonEncode(data));
  }

  Future<List<Tag>> getTags({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyTags);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTags(List<Tag> tags, {String? profileId}) async {
    final store = await _store;
    final list = tags.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyTags, jsonEncode(list));
  }

  Future<List<Debt>> getDebts({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyDebts);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Debt.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveDebts(List<Debt> debts, {String? profileId}) async {
    final store = await _store;
    final list = debts.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyDebts, jsonEncode(list));
  }

  Future<List<Investment>> getInvestments({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyInvestments);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => Investment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveInvestments(List<Investment> investments, {String? profileId}) async {
    final store = await _store;
    final list = investments.map((e) => e.toJson()).toList();
    await store.setString(_prefix(profileId) + _keyInvestments, jsonEncode(list));
  }

  Future<List<Reminder>> getReminders({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyReminders);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>?;
    if (list == null) return [];
    return list
        .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveReminders(List<Reminder> reminders,
      {String? profileId}) async {
    final store = await _store;
    final list = reminders.map((e) => e.toJson()).toList();
    await store.setString(
        _prefix(profileId) + _keyReminders, jsonEncode(list));
  }

  Future<String?> getPinHash() async {
    final store = await _store;
    return store.getString(_keyPinHash);
  }

  Future<void> setPinHash(String? hash) async {
    final store = await _store;
    if (hash == null) {
      await store.remove(_keyPinHash);
    } else {
      await store.setString(_keyPinHash, hash);
    }
  }

  Future<String?> getProfileId() async {
    final store = await _store;
    return store.getString(_keyProfileId);
  }

  Future<void> setProfileId(String? id) async {
    final store = await _store;
    if (id == null) {
      await store.remove(_keyProfileId);
    } else {
      await store.setString(_keyProfileId, id);
    }
  }

  Future<Map<String, double>> getCurrencyRates() async {
    final store = await _store;
    final raw = store.getString(_keyCurrencyRates);
    if (raw == null) return {'COP': 1.0, 'USD': 0.00024};
    final map = jsonDecode(raw) as Map<String, dynamic>?;
    if (map == null) return {'COP': 1.0, 'USD': 0.00024};
    return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<void> setCurrencyRates(Map<String, double> rates) async {
    final store = await _store;
    final map = rates.map((k, v) => MapEntry(k, v));
    await store.setString(_keyCurrencyRates, jsonEncode(map));
  }

  Future<DistributionTarget?> getDistributionTarget({String? profileId}) async {
    final store = await _store;
    final raw = store.getString(_prefix(profileId) + _keyDistributionTarget);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>?;
      if (map == null) return null;
      return DistributionTarget.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDistributionTarget(DistributionTarget target,
      {String? profileId}) async {
    final store = await _store;
    await store.setString(
        _prefix(profileId) + _keyDistributionTarget, jsonEncode(target.toJson()));
  }

  Future<int?> getInt(String key) async {
    final store = await _store;
    return store.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final store = await _store;
    await store.setInt(key, value);
  }

  Future<String?> getString(String key) async {
    final store = await _store;
    return store.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final store = await _store;
    await store.setString(key, value);
  }

  /// Exporta todos los datos como JSON (respaldo).
  Future<String> exportAllJson({String? profileId}) async {
    final p = profileId ?? await getProfileId();
    final expenses = await getExpenses(profileId: p);
    final categories = await getCategories(profileId: p);
    final incomes = await getIncomes(profileId: p);
    final accounts = await getAccounts(profileId: p);
    final transfers = await getTransfers(profileId: p);
    final budgets = await getBudgets(profileId: p);
    final goals = await getGoals(profileId: p);
    final recurring = await getRecurring(profileId: p);
    final tags = await getTags(profileId: p);
    final debts = await getDebts(profileId: p);
    final reminders = await getReminders(profileId: p);
    final investments = await getInvestments(profileId: p);
    final distTarget = await getDistributionTarget(profileId: p);
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'incomes': incomes.map((e) => e.toJson()).toList(),
      'accounts': accounts.map((e) => e.toJson()).toList(),
      'transfers': transfers.map((e) => e.toJson()).toList(),
      'investments': investments.map((e) => e.toJson()).toList(),
      'budgets': budgets.map((e) => e.toJson()).toList(),
      'savingsGoals': goals.map((e) => e.toJson()).toList(),
      'recurringExpenses': recurring.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'debts': debts.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((e) => e.toJson()).toList(),
      if (distTarget != null) 'distributionTarget': distTarget.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Restaura desde JSON (solo datos, no PIN).
  Future<void> importFromJson(String jsonStr, {String? profileId}) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final p = profileId ?? await getProfileId();
    if (data['expenses'] != null) {
      final list = (data['expenses'] as List)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveExpenses(list, profileId: p);
    }
    if (data['categories'] != null) {
      final list = (data['categories'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveCategories(list, profileId: p);
    }
    if (data['incomes'] != null) {
      final list = (data['incomes'] as List)
          .map((e) => Income.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveIncomes(list, profileId: p);
    }
    if (data['accounts'] != null) {
      final list = (data['accounts'] as List)
          .map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveAccounts(list, profileId: p);
    }
    if (data['transfers'] != null) {
      final list = (data['transfers'] as List)
          .map((e) => Transfer.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveTransfers(list, profileId: p);
    }
    if (data['budgets'] != null) {
      final list = (data['budgets'] as List)
          .map((e) => Budget.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveBudgets(list, profileId: p);
    }
    if (data['savingsGoals'] != null) {
      final list = (data['savingsGoals'] as List)
          .map((e) => SavingsGoal.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveGoals(list, profileId: p);
    }
    if (data['recurringExpenses'] != null) {
      final list = (data['recurringExpenses'] as List)
          .map((e) => RecurringExpense.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveRecurring(list, profileId: p);
    }
    if (data['tags'] != null) {
      final list = (data['tags'] as List)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveTags(list, profileId: p);
    }
    if (data['debts'] != null) {
      final list = (data['debts'] as List)
          .map((e) => Debt.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveDebts(list, profileId: p);
    }
    if (data['reminders'] != null) {
      final list = (data['reminders'] as List)
          .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveReminders(list, profileId: p);
    }
    if (data['investments'] != null) {
      final list = (data['investments'] as List)
          .map((e) => Investment.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveInvestments(list, profileId: p);
    }
    if (data['distributionTarget'] != null) {
      final target = DistributionTarget.fromJson(
          data['distributionTarget'] as Map<String, dynamic>);
      await saveDistributionTarget(target, profileId: p);
    }
  }
}
