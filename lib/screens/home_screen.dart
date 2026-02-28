import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/period_filter.dart';
import '../providers/app_state.dart';
import '../widgets/distribution_chart_card.dart';
import '../widgets/investments_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
        final income = state.periodTotalIncomes;
        final expense = state.periodTotalExpenses;
        final net = state.periodBalance;
        final savingsRate = income > 0 ? (net / income) * 100 : 0.0;

        final sortedExpenses = [...state.periodExpenses]..sort((a, b) => b.date.compareTo(a.date));
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00D9FF), Color(0xFF10B981)],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: const Text(
                        'Financial Dashboard',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Track, analyze, and optimize your personal finances',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    _DateFilterRow(
                      period: state.dashboardPeriod,
                      onPeriodChange: state.setDashboardPeriod,
                    ),
                    const SizedBox(height: 16),
                    _StatGrid(
                      cards: [
                        _StatCardData(
                          title: 'Total Income',
                          value: format.format(income),
                          icon: Icons.attach_money_rounded,
                          color: const Color(0xFF10B981),
                        ),
                        _StatCardData(
                          title: 'Total Expenses',
                          value: format.format(expense),
                          icon: Icons.account_balance_wallet_rounded,
                          color: const Color(0xFFEF4444),
                        ),
                        _StatCardData(
                          title: 'Net Balance',
                          value: format.format(net),
                          icon: Icons.trending_up_rounded,
                          color: net >= 0 ? const Color(0xFF00D9FF) : const Color(0xFFF59E0B),
                        ),
                        _StatCardData(
                          title: 'Savings Rate',
                          value: '${savingsRate.toStringAsFixed(1)}%',
                          icon: Icons.savings_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Budget Distribution', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    const DistributionChartCard(),
                    const SizedBox(height: 16),
                    _MonthlyTrendCard(state: state),
                    const SizedBox(height: 16),
                    const InvestmentsSummaryCard(),
                    const SizedBox(height: 16),
                    _ExpenseBreakdownCard(state: state),
                    const SizedBox(height: 14),
                    Text(
                      'Recent Expenses',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            if (state.periodExpenses.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No expenses in this period',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                    final expense = sortedExpenses[index];
                    final category = state.categoryById(expense.categoryId);
                    return _ExpenseTile(
                      description: expense.description.isEmpty ? 'Expense' : expense.description,
                      categoryName: category?.name ?? 'Uncategorized',
                      amount: format.format(expense.amount),
                      date: DateFormat('d MMM y', 'en').format(expense.date),
                      categoryColor: category?.color ?? scheme.primary,
                    );
                  },
                  childCount: math.min(8, sortedExpenses.length),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DateFilterRow extends StatelessWidget {
  const _DateFilterRow({
    required this.period,
    required this.onPeriodChange,
  });

  final PeriodFilter period;
  final ValueChanged<PeriodFilter> onPeriodChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _FilterChip(
          label: 'This Month',
          selected: period.type == PeriodType.currentMonth,
          onTap: () => onPeriodChange(PeriodFilter.currentMonth()),
        ),
        _FilterChip(
          label: 'Last 3 Months',
          selected: period.type == PeriodType.lastThreeMonths,
          onTap: () => onPeriodChange(PeriodFilter.lastThreeMonths()),
        ),
        _FilterChip(
          label: 'Year to Date',
          selected: period.type == PeriodType.yearToDate,
          onTap: () => onPeriodChange(PeriodFilter.yearToDate(DateTime.now().year)),
        ),
        _FilterChip(
          label: 'Full Year',
          selected: period.type == PeriodType.fullYear,
          onTap: () => onPeriodChange(PeriodFilter.fullYear(DateTime.now().year)),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0xFF00D9FF).withValues(alpha: 0.18) : scheme.surface,
          border: Border.all(
            color: selected ? const Color(0xFF00D9FF) : scheme.outline.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF00D9FF) : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.cards});

  final List<_StatCardData> cards;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = width > 1280 ? 4 : (width > 860 ? 2 : 1);
    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: columns == 1 ? 2.9 : 2.3,
      ),
      itemBuilder: (context, index) => _StatCard(data: cards[index]),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            data.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTrendCard extends StatelessWidget {
  const _MonthlyTrendCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final data = _trendData(state);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(data[idx].label, style: const TextStyle(fontSize: 11)),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(data.length, (index) {
                  final item = data[index];
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 5,
                    barRods: [
                      BarChartRodData(
                        toY: item.income / 1000,
                        color: const Color(0xFF10B981),
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: item.expense / 1000,
                        color: const Color(0xFFEF4444),
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_MonthData> _trendData(AppState state) {
    final now = DateTime.now();
    return List.generate(4, (index) {
      final monthDate = DateTime(now.year, now.month - (3 - index));
      final start = DateTime(monthDate.year, monthDate.month, 1);
      final end = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
      final income = state.totalIncomesInRange(start, end);
      final expense = state.totalExpensesInRange(start, end);
      return _MonthData(
        label: DateFormat('MMM', 'en').format(monthDate),
        income: income,
        expense: expense,
      );
    });
  }
}

class _MonthData {
  const _MonthData({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}

class _ExpenseBreakdownCard extends StatelessWidget {
  const _ExpenseBreakdownCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final byCategory = state.periodExpensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = state.periodTotalExpenses;
    final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Breakdown', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (byCategory.isEmpty)
            Text('No expense data available', style: Theme.of(context).textTheme.bodySmall)
          else
            ...byCategory.take(5).map((entry) {
              final category = state.categoryById(entry.key);
              final pct = total > 0 ? entry.value / total : 0.0;
              final color = category?.color ?? const Color(0xFF00D9FF);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(category?.name ?? 'Category')),
                        Text(format.format(entry.value)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.description,
    required this.categoryName,
    required this.amount,
    required this.date,
    required this.categoryColor,
  });

  final String description;
  final String categoryName;
  final String amount;
  final String date;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long_rounded, color: categoryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$categoryName • $date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            amount,
            style: TextStyle(color: scheme.error, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
