import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/distribution_target.dart';
import '../models/period_filter.dart';
import '../providers/app_state.dart';

/// Colores vibrantes por tipo de distribución (estilo dashboard moderno).
Color distributionColor(String key) {
  switch (key) {
    case kDistributionFundamental:
      return const Color(0xFF8B5CF6); // Púrpura vibrante
    case kDistributionFixed:
      return const Color(0xFF06B6D4); // Cyan
    case kDistributionInvestment:
      return const Color(0xFF10B981); // Verde esmeralda
    case kDistributionLibre:
      return const Color(0xFFF59E0B); // Amarillo/naranja
    default:
      return const Color(0xFF64748B);
  }
}

/// Tarjeta con gráfico circular de distribución (meta editable + realidad).
class DistributionChartCard extends StatelessWidget {
  const DistributionChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final target = state.distributionTarget;
        final reality = state.realityDistributionPercentagesInPeriod();
        final totalInc = state.periodTotalIncomes;
        final period = state.dashboardPeriod;
        final baseLabel =
            totalInc > 0 ? 'sobre ingresos' : 'sobre gastos (sin ingresos)';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pie_chart_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distribución del dinero',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Meta vs Real',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ChartSection(
                      title: 'Tu meta',
                      subtitle: 'Toca para editar',
                      target: target,
                      onTap: () => _showEditDialog(context, state),
                      isTarget: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ChartSection(
                      title: 'Real',
                      subtitle: period.shortDescription,
                      target: _targetFromReality(reality),
                      onTap: null,
                      isTarget: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _Legend(percentages: _targetToMap(target), isTarget: true),
                    const SizedBox(height: 12),
                    _Legend(percentages: reality, isTarget: false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DistributionTarget _targetFromReality(Map<String, double> reality) {
    return DistributionTarget(
      fundamental: reality[kDistributionFundamental] ?? 0,
      fixed: reality[kDistributionFixed] ?? 0,
      investment: reality[kDistributionInvestment] ?? 0,
      libre: reality[kDistributionLibre] ?? 0,
    );
  }

  Map<String, double> _targetToMap(DistributionTarget t) {
    return {
      kDistributionFundamental: t.fundamental,
      kDistributionFixed: t.fixed,
      kDistributionInvestment: t.investment,
      kDistributionLibre: t.libre,
    };
  }

  void _showEditDialog(BuildContext context, AppState state) {
    DistributionTarget current = state.distributionTarget;
    double fund = current.fundamental;
    double fixed = current.fixed;
    double inv = current.investment;
    double libre = current.libre;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          void normalize() {
            final total = fund + fixed + inv + libre;
            if (total <= 0) {
              fund = 50;
              fixed = 10;
              inv = 20;
              libre = 20;
              return;
            }
            final scale = 100 / total;
            fund = (fund * scale).roundToDouble();
            fixed = (fixed * scale).roundToDouble();
            inv = (inv * scale).roundToDouble();
            libre = (libre * scale).roundToDouble();
            final remainder = 100 - (fund + fixed + inv + libre);
            if (remainder != 0) libre += remainder;
          }

          return AlertDialog(
            title: const Text('Editar distribución ideal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SliderRow(
                    label: distributionTypeLabel(kDistributionFundamental),
                    hint: distributionTypeIdealHint(kDistributionFundamental),
                    value: fund,
                    color: distributionColor(kDistributionFundamental),
                    onChanged: (v) => setState(() => fund = v),
                  ),
                  _SliderRow(
                    label: distributionTypeLabel(kDistributionFixed),
                    hint: distributionTypeIdealHint(kDistributionFixed),
                    value: fixed,
                    color: distributionColor(kDistributionFixed),
                    onChanged: (v) => setState(() => fixed = v),
                  ),
                  _SliderRow(
                    label: distributionTypeLabel(kDistributionInvestment),
                    hint: distributionTypeIdealHint(kDistributionInvestment),
                    value: inv,
                    color: distributionColor(kDistributionInvestment),
                    onChanged: (v) => setState(() => inv = v),
                  ),
                  _SliderRow(
                    label: distributionTypeLabel(kDistributionLibre),
                    hint: distributionTypeIdealHint(kDistributionLibre),
                    value: libre,
                    color: distributionColor(kDistributionLibre),
                    onChanged: (v) => setState(() => libre = v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${(fund + fixed + inv + libre).toStringAsFixed(0)}%',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                          color: (fund + fixed + inv + libre).round() == 100
                              ? Theme.of(ctx).colorScheme.primary
                              : Theme.of(ctx).colorScheme.error,
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  normalize();
                  state.setDistributionTarget(DistributionTarget(
                    fundamental: fund,
                    fixed: fixed,
                    investment: inv,
                    libre: libre,
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.hint,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          if (hint.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 2),
              child: Text(
                hint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
            ),
            child: Slider(
              value: value.clamp(0.0, 100.0),
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.subtitle,
    required this.target,
    this.onTap,
    required this.isTarget,
  });

  final String title;
  final String subtitle;
  final DistributionTarget target;
  final VoidCallback? onTap;
  final bool isTarget;

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(target);
    final total = target.total;
    final isEmpty = total <= 0;

    Widget chart = SizedBox(
      height: 140,
      child: isEmpty
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.pie_chart_outline_rounded,
                  color: Theme.of(context).colorScheme.outline,
                  size: 40,
                ),
              ),
            )
          : PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: sections,
                pieTouchData: PieTouchData(enabled: onTap != null),
              ),
              duration: const Duration(milliseconds: 400),
            ),
    );

    if (onTap != null) {
      chart = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: chart,
        ),
      );
    }

    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        chart,
      ],
    );
  }

  List<PieChartSectionData> _buildSections(DistributionTarget t) {
    final values = [
      (t.fundamental, kDistributionFundamental),
      (t.fixed, kDistributionFixed),
      (t.investment, kDistributionInvestment),
      (t.libre, kDistributionLibre),
    ];
    final total = t.total;
    if (total <= 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.withOpacity(0.2),
          showTitle: false,
          radius: 50,
        ),
      ];
    }
    return values
        .where((e) => e.$1 > 0)
        .map(
          (e) => PieChartSectionData(
            value: e.$1,
            color: distributionColor(e.$2),
            showTitle: false,
            radius: 50,
            gradient: LinearGradient(
              colors: [
                distributionColor(e.$2),
                distributionColor(e.$2).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        )
        .toList();
  }
}

String _shortLabel(String key) {
  switch (key) {
    case kDistributionFundamental:
      return 'Fundamental';
    case kDistributionFixed:
      return 'Fijo';
    case kDistributionInvestment:
      return 'Inversión';
    case kDistributionLibre:
      return 'Libre';
    default:
      return key;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.percentages,
    required this.isTarget,
  });

  final Map<String, double> percentages;
  final bool isTarget;

  @override
  Widget build(BuildContext context) {
    final entries = distributionTypeKeys.map((key) {
      final pct = percentages[key] ?? 0;
      return MapEntry(key, pct);
    }).toList();

    return Column(
      children: entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: distributionColor(e.key),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: distributionColor(e.key).withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _shortLabel(e.key),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Text(
                    '${e.value.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: distributionColor(e.key),
                        ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
