import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/investment.dart';
import '../providers/app_state.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showProjections(context),
            tooltip: 'Ver proyecciones',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final investments = state.investments;
          final activeInvestments = state.activeInvestments;
          final totalValue = state.totalInvestmentsValue;
          final totalReturn = state.totalInvestmentsReturn;
          final returnPercent = state.totalInvestmentsReturnPercent;

          return CustomScrollView(
            slivers: [
              // Resumen
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SummaryCard(
                        totalValue: totalValue,
                        totalReturn: totalReturn,
                        returnPercent: returnPercent,
                        investmentCount: activeInvestments.length,
                        format: format,
                      ),
                      const SizedBox(height: 16),
                      if (activeInvestments.isNotEmpty) ...[
                        _ProjectionCard(
                          state: state,
                          format: format,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              // Lista de inversiones
              if (investments.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sin inversiones',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega tu primera inversión',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final investment = investments[index];
                        return _InvestmentTile(
                          investment: investment,
                          format: format,
                          onTap: () => _showInvestmentDetails(context, investment),
                          onEdit: () => _showAddEditInvestment(context, investment: investment),
                          onDelete: () => _confirmDelete(context, state, investment.id),
                        );
                      },
                      childCount: investments.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditInvestment(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Investment'),
      ),
    );
  }

  void _showAddEditInvestment(BuildContext context, {Investment? investment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddEditInvestmentSheet(investment: investment),
    );
  }

  void _showInvestmentDetails(BuildContext context, Investment investment) {
    final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y', 'es');
    final typeInfo = getInvestmentTypeInfo(investment.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeInfo.icon, color: typeInfo.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment.name,
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        typeInfo.name,
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(label: 'Valor actual', value: format.format(investment.currentValue)),
            _DetailRow(label: 'Monto invertido', value: format.format(investment.initialAmount)),
            _DetailRow(
              label: 'Ganancia/Pérdida',
              value: '${investment.totalReturn >= 0 ? '+' : ''}${format.format(investment.totalReturn)}',
              valueColor: investment.totalReturn >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
            _DetailRow(
              label: 'Rendimiento',
              value: '${investment.totalReturnPercent >= 0 ? '+' : ''}${investment.totalReturnPercent.toStringAsFixed(2)}%',
              valueColor: investment.totalReturnPercent >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
            _DetailRow(label: 'Rendimiento anualizado', value: '${investment.annualizedReturn.toStringAsFixed(2)}%/año'),
            _DetailRow(label: 'Start date', value: dateFormat.format(investment.startDate)),
            _DetailRow(label: 'Días de inversión', value: '${investment.daysHeld} días'),
            if (investment.platform != null)
              _DetailRow(label: 'Plataforma', value: investment.platform!),
            if (investment.ticker != null)
              _DetailRow(label: 'Ticker', value: investment.ticker!),
            if (investment.fixedRate != null)
              _DetailRow(label: 'Tasa fija', value: '${investment.fixedRate}% anual'),
            if (investment.maturityDate != null)
              _DetailRow(label: 'Vencimiento', value: dateFormat.format(investment.maturityDate!)),
            const SizedBox(height: 16),
            Text(
              'Proyecciones',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProjectionMiniCard(
                    label: '6 meses',
                    value: format.format(
                      typeInfo.isFixedIncome
                          ? investment.projectFixedIncome(6)
                          : investment.projectValue(6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProjectionMiniCard(
                    label: '1 año',
                    value: format.format(
                      typeInfo.isFixedIncome
                          ? investment.projectFixedIncome(12)
                          : investment.projectValue(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProjectionMiniCard(
                    label: '5 años',
                    value: format.format(
                      typeInfo.isFixedIncome
                          ? investment.projectFixedIncome(60)
                          : investment.projectValue(60),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showProjections(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final format = NumberFormat.currency(locale: 'es', symbol: '\$', decimalDigits: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Proyecciones de crecimiento',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Basado en el rendimiento histórico de tus inversiones',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            _ProjectionRow(
              label: 'Valor actual',
              value: format.format(state.totalInvestmentsValue),
              isHighlighted: true,
            ),
            const Divider(height: 32),
            _ProjectionRow(
              label: 'En 6 meses',
              value: format.format(state.projectTotalInvestments(6)),
            ),
            _ProjectionRow(
              label: 'En 1 año',
              value: format.format(state.projectTotalInvestments(12)),
            ),
            _ProjectionRow(
              label: 'En 2 años',
              value: format.format(state.projectTotalInvestments(24)),
            ),
            _ProjectionRow(
              label: 'En 5 años',
              value: format.format(state.projectTotalInvestments(60)),
            ),
            _ProjectionRow(
              label: 'En 10 años',
              value: format.format(state.projectTotalInvestments(120)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Las proyecciones son estimaciones basadas en rendimientos pasados y no garantizan resultados futuros.',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete investment'),
        content: const Text('Delete this investment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              state.removeInvestment(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalValue,
    required this.totalReturn,
    required this.returnPercent,
    required this.investmentCount,
    required this.format,
  });

  final double totalValue;
  final double totalReturn;
  final double returnPercent;
  final int investmentCount;
  final NumberFormat format;

  @override
  Widget build(BuildContext context) {
    final isPositive = totalReturn >= 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
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
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$investmentCount inversiones',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Valor total',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            format.format(totalValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${format.format(totalReturn)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${returnPercent.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectionCard extends StatelessWidget {
  const _ProjectionCard({
    required this.state,
    required this.format,
  });

  final AppState state;
  final NumberFormat format;

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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Proyección de crecimiento',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ProjectionMiniCard(
                  label: '1 año',
                  value: format.format(state.projectTotalInvestments(12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProjectionMiniCard(
                  label: '5 años',
                  value: format.format(state.projectTotalInvestments(60)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProjectionMiniCard(
                  label: '10 años',
                  value: format.format(state.projectTotalInvestments(120)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectionMiniCard extends StatelessWidget {
  const _ProjectionMiniCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF10B981),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _InvestmentTile extends StatelessWidget {
  const _InvestmentTile({
    required this.investment,
    required this.format,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Investment investment;
  final NumberFormat format;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typeInfo = getInvestmentTypeInfo(investment.type);
    final isPositive = investment.totalReturn >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
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
                    color: typeInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeInfo.icon,
                    color: typeInfo.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${typeInfo.name}${investment.platform != null ? ' • ${investment.platform}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      format.format(investment.currentValue),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: isPositive
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${isPositive ? '+' : ''}${investment.totalReturnPercent.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isPositive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'update', child: Text('Update value')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'update') _showUpdateValue(context);
                    if (v == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateValue(BuildContext context) {
    final controller = TextEditingController(text: investment.currentValue.toStringAsFixed(0));
    final state = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update value'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Valor actual',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text.replaceAll(',', '.'));
              if (newValue != null) {
                // Agregar al historial
                final newHistory = [
                  ...investment.history,
                  InvestmentReturn(
                    id: 'ret_${DateTime.now().millisecondsSinceEpoch}',
                    date: DateTime.now(),
                    value: newValue,
                    returnAmount: newValue - investment.currentValue,
                    returnPercent: investment.currentValue > 0
                        ? ((newValue - investment.currentValue) / investment.currentValue) * 100
                        : 0,
                  ),
                ];
                state.updateInvestment(investment.copyWith(
                  currentValue: newValue,
                  history: newHistory,
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionRow extends StatelessWidget {
  const _ProjectionRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.w600 : null,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHighlighted
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF10B981),
                ),
          ),
        ],
      ),
    );
  }
}

class _AddEditInvestmentSheet extends StatefulWidget {
  const _AddEditInvestmentSheet({this.investment});

  final Investment? investment;

  @override
  State<_AddEditInvestmentSheet> createState() => _AddEditInvestmentSheetState();
}

class _AddEditInvestmentSheetState extends State<_AddEditInvestmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialAmountController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _platformController = TextEditingController();
  final _tickerController = TextEditingController();
  final _fixedRateController = TextEditingController();

  InvestmentType _selectedType = InvestmentType.stocks;
  CompoundFrequency _compoundFrequency = CompoundFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _maturityDate;

  bool get _isFixedIncome => getInvestmentTypeInfo(_selectedType).isFixedIncome;

  @override
  void initState() {
    super.initState();
    if (widget.investment != null) {
      final inv = widget.investment!;
      _nameController.text = inv.name;
      _initialAmountController.text = inv.initialAmount.toStringAsFixed(0);
      _currentValueController.text = inv.currentValue.toStringAsFixed(0);
      _platformController.text = inv.platform ?? '';
      _tickerController.text = inv.ticker ?? '';
      _fixedRateController.text = inv.fixedRate?.toString() ?? '';
      _selectedType = inv.type;
      _compoundFrequency = inv.compoundFrequency ?? CompoundFrequency.monthly;
      _startDate = inv.startDate;
      _maturityDate = inv.maturityDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _currentValueController.dispose();
    _platformController.dispose();
    _tickerController.dispose();
    _fixedRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.investment != null;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isEditing ? 'Edit investment' : 'New investment',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Tipo de inversión
                Text(
                  'Tipo de inversión',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: investmentTypes.map((typeInfo) {
                    final isSelected = _selectedType == typeInfo.type;
                    return InkWell(
                      onTap: () => setState(() => _selectedType = typeInfo.type),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? typeInfo.color
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? typeInfo.color
                                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              typeInfo.icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              typeInfo.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.w600 : null,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la inversión',
                    hintText: 'Ej: ETF S&P 500, CDT Bancolombia...',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _initialAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Monto invertido',
                          prefixText: '\$ ',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _currentValueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Valor actual',
                          prefixText: '\$ ',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Inválido';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _platformController,
                        decoration: const InputDecoration(
                          labelText: 'Plataforma (opcional)',
                          hintText: 'Ej: Tyba, a]2, Binance...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _tickerController,
                        decoration: const InputDecoration(
                          labelText: 'Ticker (opcional)',
                          hintText: 'Ej: VOO, BTC...',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Fecha de inicio
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start date'),
                  subtitle: Text(
                    DateFormat('d MMM y', 'es').format(_startDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setState(() => _startDate = date);
                  },
                ),

                // Campos para renta fija
                if (_isFixedIncome) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fixedRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tasa de interés anual (%)',
                      hintText: 'Ej: 12.5',
                      suffixText: '%',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CompoundFrequency>(
                    value: _compoundFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frecuencia de capitalización',
                    ),
                    items: const [
                      DropdownMenuItem(value: CompoundFrequency.daily, child: Text('Daily')),
                      DropdownMenuItem(value: CompoundFrequency.monthly, child: Text('Monthly')),
                      DropdownMenuItem(value: CompoundFrequency.quarterly, child: Text('Quarterly')),
                      DropdownMenuItem(value: CompoundFrequency.semiannual, child: Text('Semiannual')),
                      DropdownMenuItem(value: CompoundFrequency.annual, child: Text('Annual')),
                      DropdownMenuItem(value: CompoundFrequency.atMaturity, child: Text('At maturity')),
                    ],
                    onChanged: (v) => setState(() => _compoundFrequency = v!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Maturity date'),
                    subtitle: Text(
                      _maturityDate != null
                          ? DateFormat('d MMM y', 'es').format(_maturityDate!)
                          : 'Sin definir',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _maturityDate ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _maturityDate = date);
                    },
                  ),
                ],

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(isEditing ? 'Save' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final state = Provider.of<AppState>(context, listen: false);
    final initialAmount = double.parse(_initialAmountController.text.replaceAll(',', '.'));
    final currentValue = double.parse(_currentValueController.text.replaceAll(',', '.'));
    final fixedRate = _fixedRateController.text.isNotEmpty
        ? double.tryParse(_fixedRateController.text.replaceAll(',', '.'))
        : null;

    final investment = Investment(
      id: widget.investment?.id ?? 'inv_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      type: _selectedType,
      initialAmount: initialAmount,
      currentValue: currentValue,
      startDate: _startDate,
      maturityDate: _maturityDate,
      fixedRate: fixedRate,
      compoundFrequency: _isFixedIncome ? _compoundFrequency : null,
      platform: _platformController.text.trim().isEmpty ? null : _platformController.text.trim(),
      ticker: _tickerController.text.trim().isEmpty ? null : _tickerController.text.trim(),
      history: widget.investment?.history ?? [],
      isActive: true,
    );

    if (widget.investment != null) {
      state.updateInvestment(investment);
    } else {
      state.addInvestment(investment);
    }

    Navigator.pop(context);
  }
}
