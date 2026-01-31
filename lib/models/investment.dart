import 'package:flutter/material.dart';

/// Tipos de inversión soportados
enum InvestmentType {
  stocks,       // Acciones
  etf,          // ETF / Fondos indexados
  crypto,       // Criptomonedas
  cdt,          // CDT / Depósitos a plazo fijo
  bonds,        // Bonos
  realEstate,   // Bienes raíces / FICs
  mutualFund,   // Fondos mutuos
  savings,      // Cuenta de ahorros con rendimiento
  pension,      // Fondo de pensiones voluntarias
  other,        // Otros
}

/// Frecuencia de capitalización para inversiones de renta fija
enum CompoundFrequency {
  daily,
  monthly,
  quarterly,
  semiannual,
  annual,
  atMaturity,
}

/// Registro de rendimiento histórico de una inversión
class InvestmentReturn {
  final String id;
  final DateTime date;
  final double value;           // Valor total en esa fecha
  final double? returnAmount;   // Ganancia/pérdida en ese período
  final double? returnPercent;  // % de rendimiento
  final String? note;

  const InvestmentReturn({
    required this.id,
    required this.date,
    required this.value,
    this.returnAmount,
    this.returnPercent,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'value': value,
    'returnAmount': returnAmount,
    'returnPercent': returnPercent,
    'note': note,
  };

  static InvestmentReturn fromJson(Map<String, dynamic> json) => InvestmentReturn(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    value: (json['value'] as num).toDouble(),
    returnAmount: (json['returnAmount'] as num?)?.toDouble(),
    returnPercent: (json['returnPercent'] as num?)?.toDouble(),
    note: json['note'] as String?,
  );
}

/// Inversión activa
class Investment {
  final String id;
  final String name;
  final InvestmentType type;
  final double initialAmount;       // Monto inicial invertido
  final double currentValue;        // Valor actual
  final DateTime startDate;         // Fecha de inicio
  final DateTime? maturityDate;     // Fecha de vencimiento (para CDT, bonos, etc.)
  final double? fixedRate;          // Tasa fija anual (para CDT, bonos)
  final CompoundFrequency? compoundFrequency; // Frecuencia de capitalización
  final String? platform;           // Plataforma/broker (ej: Tyba, a]2, Binance)
  final String? ticker;             // Símbolo (para acciones, ETF, crypto)
  final String currency;            // Moneda
  final List<InvestmentReturn> history; // Historial de rendimientos
  final String? notes;
  final bool isActive;

  const Investment({
    required this.id,
    required this.name,
    required this.type,
    required this.initialAmount,
    required this.currentValue,
    required this.startDate,
    this.maturityDate,
    this.fixedRate,
    this.compoundFrequency,
    this.platform,
    this.ticker,
    this.currency = 'COP',
    this.history = const [],
    this.notes,
    this.isActive = true,
  });

  /// Ganancia/pérdida total
  double get totalReturn => currentValue - initialAmount;

  /// Porcentaje de retorno total
  double get totalReturnPercent => initialAmount > 0 
      ? (totalReturn / initialAmount) * 100 
      : 0;

  /// Días desde el inicio
  int get daysHeld => DateTime.now().difference(startDate).inDays;

  /// Retorno anualizado (basado en el tiempo que se ha tenido)
  double get annualizedReturn {
    if (daysHeld <= 0 || initialAmount <= 0) return 0;
    final years = daysHeld / 365.0;
    if (years <= 0) return totalReturnPercent;
    // Fórmula: ((valor_final / valor_inicial) ^ (1/años) - 1) * 100
    final ratio = currentValue / initialAmount;
    if (ratio <= 0) return -100;
    return (pow(ratio, 1 / years) - 1) * 100;
  }

  /// Promedio de retorno mensual basado en historial
  double get averageMonthlyReturn {
    if (history.isEmpty) return 0;
    final returns = history.where((h) => h.returnPercent != null).toList();
    if (returns.isEmpty) return 0;
    return returns.map((h) => h.returnPercent!).reduce((a, b) => a + b) / returns.length;
  }

  /// Proyección del valor a X meses usando el rendimiento histórico
  double projectValue(int months, {double? customRate}) {
    final monthlyRate = customRate ?? (annualizedReturn / 12);
    if (monthlyRate == 0) return currentValue;
    
    double projected = currentValue;
    for (int i = 0; i < months; i++) {
      projected *= (1 + monthlyRate / 100);
    }
    return projected;
  }

  /// Proyección para inversión de renta fija (CDT, bonos)
  double projectFixedIncome(int months) {
    if (fixedRate == null || fixedRate == 0) return currentValue;
    
    final periodsPerYear = switch (compoundFrequency) {
      CompoundFrequency.daily => 365,
      CompoundFrequency.monthly => 12,
      CompoundFrequency.quarterly => 4,
      CompoundFrequency.semiannual => 2,
      CompoundFrequency.annual => 1,
      CompoundFrequency.atMaturity => 1,
      null => 12,
    };
    
    final rate = fixedRate! / 100;
    final periods = months * periodsPerYear / 12;
    
    if (compoundFrequency == CompoundFrequency.atMaturity) {
      // Interés simple
      return currentValue * (1 + rate * months / 12);
    }
    
    // Interés compuesto
    return currentValue * pow(1 + rate / periodsPerYear, periods);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'initialAmount': initialAmount,
    'currentValue': currentValue,
    'startDate': startDate.toIso8601String(),
    'maturityDate': maturityDate?.toIso8601String(),
    'fixedRate': fixedRate,
    'compoundFrequency': compoundFrequency?.name,
    'platform': platform,
    'ticker': ticker,
    'currency': currency,
    'history': history.map((h) => h.toJson()).toList(),
    'notes': notes,
    'isActive': isActive,
  };

  static Investment fromJson(Map<String, dynamic> json) {
    final historyRaw = json['history'] as List<dynamic>?;
    return Investment(
      id: json['id'] as String,
      name: json['name'] as String,
      type: InvestmentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => InvestmentType.other,
      ),
      initialAmount: (json['initialAmount'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      maturityDate: json['maturityDate'] != null 
          ? DateTime.parse(json['maturityDate'] as String) 
          : null,
      fixedRate: (json['fixedRate'] as num?)?.toDouble(),
      compoundFrequency: json['compoundFrequency'] != null
          ? CompoundFrequency.values.firstWhere(
              (f) => f.name == json['compoundFrequency'],
              orElse: () => CompoundFrequency.monthly,
            )
          : null,
      platform: json['platform'] as String?,
      ticker: json['ticker'] as String?,
      currency: json['currency'] as String? ?? 'COP',
      history: historyRaw != null
          ? historyRaw.map((h) => InvestmentReturn.fromJson(h as Map<String, dynamic>)).toList()
          : [],
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Investment copyWith({
    String? id,
    String? name,
    InvestmentType? type,
    double? initialAmount,
    double? currentValue,
    DateTime? startDate,
    DateTime? maturityDate,
    double? fixedRate,
    CompoundFrequency? compoundFrequency,
    String? platform,
    String? ticker,
    String? currency,
    List<InvestmentReturn>? history,
    String? notes,
    bool? isActive,
  }) => Investment(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    initialAmount: initialAmount ?? this.initialAmount,
    currentValue: currentValue ?? this.currentValue,
    startDate: startDate ?? this.startDate,
    maturityDate: maturityDate ?? this.maturityDate,
    fixedRate: fixedRate ?? this.fixedRate,
    compoundFrequency: compoundFrequency ?? this.compoundFrequency,
    platform: platform ?? this.platform,
    ticker: ticker ?? this.ticker,
    currency: currency ?? this.currency,
    history: history ?? this.history,
    notes: notes ?? this.notes,
    isActive: isActive ?? this.isActive,
  );
}

/// Helper para pow
double pow(double base, double exponent) {
  if (exponent == 0) return 1;
  if (base <= 0) return 0;
  
  // Aproximación usando series de Taylor para casos donde dart:math no está disponible
  double result = 1;
  double term = 1;
  final lnBase = _ln(base);
  final x = exponent * lnBase;
  
  for (int i = 1; i <= 100; i++) {
    term *= x / i;
    result += term;
    if (term.abs() < 1e-10) break;
  }
  
  return result;
}

double _ln(double x) {
  if (x <= 0) return double.negativeInfinity;
  if (x == 1) return 0;
  
  // ln(x) usando series para x cercano a 1
  final y = (x - 1) / (x + 1);
  double result = 0;
  double term = y;
  
  for (int i = 1; i <= 100; i += 2) {
    result += term / i;
    term *= y * y;
    if (term.abs() < 1e-10) break;
  }
  
  return 2 * result;
}

/// Información del tipo de inversión
class InvestmentTypeInfo {
  final InvestmentType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isFixedIncome;
  final double? typicalReturnMin;
  final double? typicalReturnMax;

  const InvestmentTypeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isFixedIncome = false,
    this.typicalReturnMin,
    this.typicalReturnMax,
  });
}

final List<InvestmentTypeInfo> investmentTypes = [
  InvestmentTypeInfo(
    type: InvestmentType.stocks,
    name: 'Acciones',
    description: 'Acciones individuales de empresas',
    icon: Icons.show_chart,
    color: Color(0xFF3B82F6),
    typicalReturnMin: -20,
    typicalReturnMax: 30,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.etf,
    name: 'ETF / Fondos indexados',
    description: 'Fondos que replican índices bursátiles',
    icon: Icons.pie_chart,
    color: Color(0xFF8B5CF6),
    typicalReturnMin: 5,
    typicalReturnMax: 15,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.crypto,
    name: 'Criptomonedas',
    description: 'Bitcoin, Ethereum y otras criptos',
    icon: Icons.currency_bitcoin,
    color: Color(0xFFF59E0B),
    typicalReturnMin: -50,
    typicalReturnMax: 100,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.cdt,
    name: 'CDT',
    description: 'Certificado de Depósito a Término',
    icon: Icons.lock_clock,
    color: Color(0xFF10B981),
    isFixedIncome: true,
    typicalReturnMin: 8,
    typicalReturnMax: 14,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.bonds,
    name: 'Bonos',
    description: 'Bonos del gobierno o corporativos',
    icon: Icons.account_balance,
    color: Color(0xFF06B6D4),
    isFixedIncome: true,
    typicalReturnMin: 6,
    typicalReturnMax: 12,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.realEstate,
    name: 'Bienes raíces / FICs',
    description: 'Inversiones inmobiliarias o fondos',
    icon: Icons.home_work,
    color: Color(0xFFEC4899),
    typicalReturnMin: 5,
    typicalReturnMax: 15,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.mutualFund,
    name: 'Fondos mutuos',
    description: 'Fondos de inversión colectiva',
    icon: Icons.groups,
    color: Color(0xFF14B8A6),
    typicalReturnMin: 4,
    typicalReturnMax: 12,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.savings,
    name: 'Cuenta de ahorros',
    description: 'Cuenta con rendimiento',
    icon: Icons.savings,
    color: Color(0xFF22C55E),
    isFixedIncome: true,
    typicalReturnMin: 2,
    typicalReturnMax: 6,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.pension,
    name: 'Pensiones voluntarias',
    description: 'Fondo de pensiones voluntarias',
    icon: Icons.elderly,
    color: Color(0xFF6366F1),
    typicalReturnMin: 5,
    typicalReturnMax: 12,
  ),
  InvestmentTypeInfo(
    type: InvestmentType.other,
    name: 'Otros',
    description: 'Otras inversiones',
    icon: Icons.more_horiz,
    color: Color(0xFF64748B),
  ),
];

InvestmentTypeInfo getInvestmentTypeInfo(InvestmentType type) {
  return investmentTypes.firstWhere(
    (t) => t.type == type,
    orElse: () => investmentTypes.last,
  );
}
