import 'package:flutter/material.dart';

import '../../screens/app_section.dart';

class FinanceNavigation extends StatelessWidget {
  const FinanceNavigation({
    super.key,
    required this.activeSection,
    required this.onSectionChange,
  });

  final AppSection activeSection;
  final ValueChanged<AppSection> onSectionChange;

  static const _desktopBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= _desktopBreakpoint;
    if (isDesktop) {
      return _DesktopSidebar(
        activeSection: activeSection,
        onSectionChange: onSectionChange,
      );
    }
    return _MobileBottomNav(
      activeSection: activeSection,
      onSectionChange: onSectionChange,
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.activeSection,
    required this.onSectionChange,
  });

  final AppSection activeSection;
  final ValueChanged<AppSection> onSectionChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.62),
        border: Border(right: BorderSide(color: scheme.outline.withValues(alpha: 0.25))),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF10B981)],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      'FinanceApp',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personal Finance Manager',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: AppSection.values
                    .map(
                      (section) => _NavItem(
                        section: section,
                        selected: activeSection == section,
                        onTap: () => onSectionChange(section),
                      ),
                    )
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Quick Tip: Track every transaction for more accurate spending insights.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav({
    required this.activeSection,
    required this.onSectionChange,
  });

  final AppSection activeSection;
  final ValueChanged<AppSection> onSectionChange;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.25))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: AppSection.values.map((section) {
              final selected = activeSection == section;
              final color = selected ? const Color(0xFF00D9FF) : scheme.onSurfaceVariant;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSectionChange(section),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_iconForSection(section), size: 20, color: color),
                        const SizedBox(height: 2),
                        Text(
                          section.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final AppSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? const Color(0xFF00D9FF) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                _iconForSection(section),
                color: selected ? const Color(0xFF0A0E1A) : scheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                section.label,
                style: TextStyle(
                  color: selected ? const Color(0xFF0A0E1A) : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForSection(AppSection section) {
  switch (section) {
    case AppSection.dashboard:
      return Icons.dashboard_rounded;
    case AppSection.budget:
      return Icons.pie_chart_rounded;
    case AppSection.transactions:
      return Icons.receipt_long_rounded;
    case AppSection.debts:
      return Icons.credit_card_rounded;
    case AppSection.investments:
      return Icons.trending_up_rounded;
    case AppSection.wishlist:
      return Icons.favorite_rounded;
    case AppSection.reports:
      return Icons.description_rounded;
  }
}
