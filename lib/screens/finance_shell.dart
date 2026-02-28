import 'package:flutter/material.dart';

import '../widgets/navigation/finance_navigation.dart';
import 'analytics_screen.dart';
import 'app_section.dart';
import 'budgets_screen.dart';
import 'debts_screen.dart';
import 'goals_screen.dart';
import 'home_screen.dart';
import 'investments_screen.dart';
import 'transactions_screen.dart';

class FinanceShell extends StatefulWidget {
  const FinanceShell({
    super.key,
    this.initialSection = AppSection.dashboard,
  });

  final AppSection initialSection;

  @override
  State<FinanceShell> createState() => _FinanceShellState();
}

class _FinanceShellState extends State<FinanceShell> {
  static const _desktopBreakpoint = 900.0;
  late AppSection _activeSection;
  bool _mobileMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _activeSection = widget.initialSection;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _desktopBreakpoint;
    final body = _sectionBody();
    final showShellAppBar = _activeSection == AppSection.dashboard || _activeSection == AppSection.transactions;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            FinanceNavigation(
              activeSection: _activeSection,
              onSectionChange: _handleSectionChange,
            ),
            Expanded(
              child: SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: KeyedSubtree(
                    key: ValueKey(_activeSection),
                    child: body,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: showShellAppBar
          ? AppBar(
              title: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF10B981)],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: const Text(
                  'FinanceApp',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => setState(() => _mobileMenuOpen = !_mobileMenuOpen),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: KeyedSubtree(
                key: ValueKey(_activeSection),
                child: body,
              ),
            ),
          ),
          if (_mobileMenuOpen && showShellAppBar)
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: AppSection.values.map((section) {
                      return ListTile(
                        dense: true,
                        selected: section == _activeSection,
                        selectedTileColor: const Color(0xFF00D9FF).withValues(alpha: 0.16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        title: Text(section.label),
                        onTap: () {
                          _handleSectionChange(section);
                          setState(() => _mobileMenuOpen = false);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: FinanceNavigation(
        activeSection: _activeSection,
        onSectionChange: _handleSectionChange,
      ),
    );
  }

  void _handleSectionChange(AppSection section) {
    if (_activeSection == section) return;
    setState(() => _activeSection = section);
  }

  Widget _sectionBody() {
    switch (_activeSection) {
      case AppSection.dashboard:
        return const HomeScreen();
      case AppSection.budget:
        return const BudgetsScreen();
      case AppSection.transactions:
        return const TransactionsScreen();
      case AppSection.debts:
        return const DebtsScreen();
      case AppSection.investments:
        return const InvestmentsScreen();
      case AppSection.wishlist:
        return const GoalsScreen();
      case AppSection.reports:
        return const AnalyticsScreen();
    }
  }
}
