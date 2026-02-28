import 'dart:convert';

import 'package:supabase/supabase.dart';

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
import 'supabase_config.dart';

const _table = 'app_kv_store';
const _globalProfile = 'global';

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

class StorageService {
  SupabaseClient get _client {
    return SupabaseConfig.client;
  }

  String _profile(String? profileId) =>
      profileId != null && profileId.isNotEmpty ? profileId : _globalProfile;

  Future<Map<String, dynamic>?> _row({
    required String key,
    String? profileId,
  }) {
    return _client
        .from(_table)
        .select('value_json,value_text,value_int')
        .eq('profile_id', _profile(profileId))
        .eq('store_key', key)
        .maybeSingle();
  }

  Future<void> _setJson(
    String key,
    Object? value, {
    String? profileId,
  }) {
    return _client.from(_table).upsert(
      {
        'profile_id': _profile(profileId),
        'store_key': key,
        'value_json': value,
        'value_text': null,
        'value_int': null,
      },
      onConflict: 'profile_id,store_key',
    );
  }

  Future<void> _setText(
    String key,
    String? value, {
    String? profileId,
  }) async {
    if (value == null) {
      await _client
          .from(_table)
          .delete()
          .eq('profile_id', _profile(profileId))
          .eq('store_key', key);
      return;
    }
    await _client.from(_table).upsert(
      {
        'profile_id': _profile(profileId),
        'store_key': key,
        'value_json': null,
        'value_text': value,
        'value_int': null,
      },
      onConflict: 'profile_id,store_key',
    );
  }

  Future<void> _setInt(
    String key,
    int value, {
    String? profileId,
  }) {
    return _client.from(_table).upsert(
      {
        'profile_id': _profile(profileId),
        'store_key': key,
        'value_json': null,
        'value_text': null,
        'value_int': value,
      },
      onConflict: 'profile_id,store_key',
    );
  }

  List<T> _decodeList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<Expense>> getExpenses({String? profileId}) async {
    final raw = (await _row(key: _keyExpenses, profileId: profileId))?['value_json'];
    return _decodeList(raw, Expense.fromJson);
  }

  Future<void> saveExpenses(List<Expense> expenses, {String? profileId}) {
    return _setJson(
      _keyExpenses,
      expenses.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Category>> getCategories({String? profileId}) async {
    final raw = (await _row(key: _keyCategories, profileId: profileId))?['value_json'];
    final categories = _decodeList(raw, Category.fromJson);
    if (categories.isEmpty) return defaultCategories;
    return categories;
  }

  Future<void> saveCategories(List<Category> categories, {String? profileId}) {
    return _setJson(
      _keyCategories,
      categories.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Income>> getIncomes({String? profileId}) async {
    final raw = (await _row(key: _keyIncomes, profileId: profileId))?['value_json'];
    return _decodeList(raw, Income.fromJson);
  }

  Future<void> saveIncomes(List<Income> incomes, {String? profileId}) {
    return _setJson(
      _keyIncomes,
      incomes.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Account>> getAccounts({String? profileId}) async {
    final raw = (await _row(key: _keyAccounts, profileId: profileId))?['value_json'];
    final accounts = _decodeList(raw, Account.fromJson);
    if (accounts.isEmpty) {
      return [const Account(id: 'default', name: 'Principal')];
    }
    return accounts;
  }

  Future<void> saveAccounts(List<Account> accounts, {String? profileId}) {
    return _setJson(
      _keyAccounts,
      accounts.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Transfer>> getTransfers({String? profileId}) async {
    final raw = (await _row(key: _keyTransfers, profileId: profileId))?['value_json'];
    return _decodeList(raw, Transfer.fromJson);
  }

  Future<void> saveTransfers(List<Transfer> transfers, {String? profileId}) {
    return _setJson(
      _keyTransfers,
      transfers.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Budget>> getBudgets({String? profileId}) async {
    final raw = (await _row(key: _keyBudgets, profileId: profileId))?['value_json'];
    return _decodeList(raw, Budget.fromJson);
  }

  Future<void> saveBudgets(List<Budget> budgets, {String? profileId}) {
    return _setJson(
      _keyBudgets,
      budgets.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<SavingsGoal>> getGoals({String? profileId}) async {
    final raw = (await _row(key: _keyGoals, profileId: profileId))?['value_json'];
    return _decodeList(raw, SavingsGoal.fromJson);
  }

  Future<void> saveGoals(List<SavingsGoal> goals, {String? profileId}) {
    return _setJson(
      _keyGoals,
      goals.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<RecurringExpense>> getRecurring({String? profileId}) async {
    final raw = (await _row(key: _keyRecurring, profileId: profileId))?['value_json'];
    return _decodeList(raw, RecurringExpense.fromJson);
  }

  Future<void> saveRecurring(List<RecurringExpense> list, {String? profileId}) {
    return _setJson(
      _keyRecurring,
      list.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Tag>> getTags({String? profileId}) async {
    final raw = (await _row(key: _keyTags, profileId: profileId))?['value_json'];
    return _decodeList(raw, Tag.fromJson);
  }

  Future<void> saveTags(List<Tag> tags, {String? profileId}) {
    return _setJson(
      _keyTags,
      tags.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Debt>> getDebts({String? profileId}) async {
    final raw = (await _row(key: _keyDebts, profileId: profileId))?['value_json'];
    return _decodeList(raw, Debt.fromJson);
  }

  Future<void> saveDebts(List<Debt> debts, {String? profileId}) {
    return _setJson(
      _keyDebts,
      debts.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Investment>> getInvestments({String? profileId}) async {
    final raw = (await _row(key: _keyInvestments, profileId: profileId))?['value_json'];
    return _decodeList(raw, Investment.fromJson);
  }

  Future<void> saveInvestments(List<Investment> investments, {String? profileId}) {
    return _setJson(
      _keyInvestments,
      investments.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<List<Reminder>> getReminders({String? profileId}) async {
    final raw = (await _row(key: _keyReminders, profileId: profileId))?['value_json'];
    return _decodeList(raw, Reminder.fromJson);
  }

  Future<void> saveReminders(List<Reminder> reminders, {String? profileId}) {
    return _setJson(
      _keyReminders,
      reminders.map((e) => e.toJson()).toList(),
      profileId: profileId,
    );
  }

  Future<String?> getPinHash() async {
    return (await _row(key: _keyPinHash))?['value_text'] as String?;
  }

  Future<void> setPinHash(String? hash) {
    return _setText(_keyPinHash, hash);
  }

  Future<String?> getProfileId() async {
    return (await _row(key: _keyProfileId))?['value_text'] as String?;
  }

  Future<void> setProfileId(String? id) {
    return _setText(_keyProfileId, id);
  }

  Future<Map<String, double>> getCurrencyRates() async {
    final raw = (await _row(key: _keyCurrencyRates))?['value_json'];
    if (raw is! Map) return {'COP': 1.0, 'USD': 0.00024};
    return Map<String, dynamic>.from(raw).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
  }

  Future<void> setCurrencyRates(Map<String, double> rates) {
    return _setJson(_keyCurrencyRates, rates);
  }

  Future<DistributionTarget?> getDistributionTarget({String? profileId}) async {
    final raw = (await _row(key: _keyDistributionTarget, profileId: profileId))?['value_json'];
    if (raw is! Map) return null;
    return DistributionTarget.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> saveDistributionTarget(DistributionTarget target, {String? profileId}) {
    return _setJson(_keyDistributionTarget, target.toJson(), profileId: profileId);
  }

  Future<int?> getInt(String key) async {
    final value = (await _row(key: key))?['value_int'];
    return value is int ? value : (value as num?)?.toInt();
  }

  Future<void> setInt(String key, int value) {
    return _setInt(key, value);
  }

  Future<String?> getString(String key) async {
    return (await _row(key: key))?['value_text'] as String?;
  }

  Future<void> setString(String key, String value) {
    return _setText(key, value);
  }

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
        data['distributionTarget'] as Map<String, dynamic>,
      );
      await saveDistributionTarget(target, profileId: p);
    }
  }
}
