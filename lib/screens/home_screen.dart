import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/app_state.dart';
import '../widgets/distribution_chart_card.dart';
import '../widgets/investments_summary_card.dart';
import '../widgets/period_selector.dart';
import 'accounts_screen.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'budgets_screen.dart';
import 'categories_screen.dart';
import 'debts_screen.dart';
import 'goals_screen.dart';
import 'incomes_screen.dart';
import 'investments_screen.dart';
import 'recurring_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import 'transfers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(Icons.menu_rounded, size: 20),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(Icons.search, size: 20),
                ),
                onPressed: () => _showSearchFilter(context),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(Icons.filter_list, size: 20),
                ),
                onPressed: () => _showFilterSheet(context),
              ),
              const SizedBox(width: 16),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bienvenido de vuelta',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<AppState>(
                builder: (context, state, _) {
                  if (!state.loaded) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  // Usar valores del período seleccionado
                  final totalExp = state.periodTotalExpenses;
                  final totalInc = state.periodTotalIncomes;
                  final balance = state.periodBalance;
                  final period = state.dashboardPeriod;
                  final format = NumberFormat.currency(
                    locale: 'es',
                    symbol: '\$',
                    decimalDigits: 0,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Selector de período
                      const PeriodSelector(),
                      const SizedBox(height: 16),
                      // Balance Cards Row
                      Row(
                        children: [
                          Expanded(
                            child: _BalanceCard(
                              title: 'Balance ${period.shortDescription}',
                              amount: format.format(balance),
                              isPositive: balance >= 0,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniBalanceCard(
                              title: 'Ingresos',
                              amount: format.format(totalInc),
                              icon: Icons.trending_up,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniBalanceCard(
                              title: 'Gastos',
                              amount: format.format(totalExp),
                              icon: Icons.trending_down,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const DistributionChartCard(),
                      const SizedBox(height: 20),
                      const InvestmentsSummaryCard(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            'Actividad ${period.shortDescription}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Ver todo',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ),
          Consumer<AppState>(
            builder: (context, state, _) {
              // Usar gastos del período seleccionado
              final periodExpenses = state.periodExpenses;
              if (!state.loaded || periodExpenses.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sin gastos en este período',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca + para agregar el primero',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              // Ordenar por fecha más reciente
              final sortedExpenses = [...periodExpenses]
                ..sort((a, b) => b.date.compareTo(a.date));
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = sortedExpenses[index];
                      final category = state.categoryById(expense.categoryId);
                      return _ExpenseTile(
                        expense: expense,
                        categoryName: category?.name ?? 'Sin categoría',
                        categoryColor: category?.color ?? Theme.of(context).colorScheme.primary,
                        onDelete: () => _confirmDelete(context, state, expense.id),
                      );
                    },
                    childCount: sortedExpenses.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddExpenseScreen(),
          ),
        ),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Agregar Gasto',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        elevation: 6,
      ),
    );
  }

  void _showSearchFilter(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buscar'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Descripción...'),
          onChanged: (v) => state.setSearchQuery(v),
        ),
        actions: [
          TextButton(
            onPressed: () {
              state.setSearchQuery('');
              Navigator.pop(ctx);
            },
            child: const Text('Limpiar'),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Listo')),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Filtrar por categoría', style: TextStyle(fontWeight: FontWeight.bold)),
            ...state.rootCategories.take(8).map((c) => ListTile(
              title: Text(c.name),
              onTap: () {
                state.setFilterCategory(state.filterCategoryId == c.id ? null : c.id);
                Navigator.pop(ctx);
              },
            )),
            ListTile(title: const Text('Limpiar filtros'), onTap: () {
              state.clearFilters();
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mis Finanzas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dashboard Personal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerItem(icon: Icons.dashboard_rounded, title: 'Dashboard', onTap: () => Navigator.pop(context)),
            _DrawerItem(icon: Icons.add_circle_outline, title: 'Agregar gasto', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())); }),
            _DrawerItem(icon: Icons.trending_up, title: 'Ingresos', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const IncomesScreen())); }),
            _DrawerItem(icon: Icons.category_rounded, title: 'Categorías', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())); }),
            _DrawerItem(icon: Icons.account_balance_wallet_outlined, title: 'Cuentas', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountsScreen())); }),
            _DrawerItem(icon: Icons.swap_horiz_rounded, title: 'Transferencias', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TransfersScreen())); }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(),
            ),
            _DrawerItem(icon: Icons.pie_chart_outline_rounded, title: 'Presupuestos', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetsScreen())); }),
            _DrawerItem(icon: Icons.savings_outlined, title: 'Metas de ahorro', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())); }),
            _DrawerItem(icon: Icons.trending_up_rounded, title: 'Inversiones', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentsScreen())); }),
            _DrawerItem(icon: Icons.repeat_rounded, title: 'Recurrentes', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringScreen())); }),
            _DrawerItem(icon: Icons.notifications_outlined, title: 'Recordatorios', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())); }),
            _DrawerItem(icon: Icons.money_off_rounded, title: 'Deudas', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen())); }),
            _DrawerItem(icon: Icons.bar_chart_rounded, title: 'Análisis', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())); }),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(),
            ),
            _DrawerItem(icon: Icons.settings_outlined, title: 'Ajustes', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text(
          '¿Quieres eliminar este gasto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              state.removeExpense(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, size: 22),
        title: Text(title),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.isPositive,
    required this.gradient,
  });

  final String title;
  final String amount;
  final bool isPositive;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: -1,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniBalanceCard extends StatelessWidget {
  const _MiniBalanceCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.categoryName,
    required this.categoryColor,
    required this.onDelete,
  });

  final Expense expense;
  final String categoryName;
  final Color categoryColor;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM', 'es');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_rounded,
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description.isEmpty ? 'Sin descripción' : expense.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$categoryName · ${dateFormat.format(expense.date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                format.format(expense.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
