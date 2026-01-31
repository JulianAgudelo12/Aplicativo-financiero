/// Meta de distribución del dinero en 4 categorías (porcentajes que suman 100).
class DistributionTarget {
  final double fundamental;  // Gastos fundamentales (ideal ≤50%)
  final double fixed;        // Gastos fijos (ideal ≤10%, fundamental+fijo ≤60%)
  final double investment;   // Inversiones/Deudas/Ahorro (ideal 20%)
  final double libre;        // Libre (ideal 20%)

  const DistributionTarget({
    this.fundamental = 50,
    this.fixed = 10,
    this.investment = 20,
    this.libre = 20,
  });

  double get total => fundamental + fixed + investment + libre;

  Map<String, dynamic> toJson() => {
        'fundamental': fundamental,
        'fixed': fixed,
        'investment': investment,
        'libre': libre,
      };

  static DistributionTarget fromJson(Map<String, dynamic> json) =>
      DistributionTarget(
        fundamental: (json['fundamental'] as num?)?.toDouble() ?? 50,
        fixed: (json['fixed'] as num?)?.toDouble() ?? 10,
        investment: (json['investment'] as num?)?.toDouble() ?? 20,
        libre: (json['libre'] as num?)?.toDouble() ?? 20,
      );

  DistributionTarget copyWith({
    double? fundamental,
    double? fixed,
    double? investment,
    double? libre,
  }) =>
      DistributionTarget(
        fundamental: fundamental ?? this.fundamental,
        fixed: fixed ?? this.fixed,
        investment: investment ?? this.investment,
        libre: libre ?? this.libre,
      );
}

/// Claves para tipos de distribución (alineadas con categorías).
const String kDistributionFundamental = 'fundamental';
const String kDistributionFixed = 'fixed';
const String kDistributionInvestment = 'investment';
const String kDistributionLibre = 'libre';

List<String> get distributionTypeKeys =>
    [kDistributionFundamental, kDistributionFixed, kDistributionInvestment, kDistributionLibre];

String distributionTypeLabel(String key) {
  switch (key) {
    case kDistributionFundamental:
      return 'Gastos fundamentales';
    case kDistributionFixed:
      return 'Gastos fijos';
    case kDistributionInvestment:
      return 'Inversiones/Deudas/Ahorro';
    case kDistributionLibre:
      return 'Libre';
    default:
      return key;
  }
}

String distributionTypeIdealHint(String key) {
  switch (key) {
    case kDistributionFundamental:
      return 'Ideal ≤50%';
    case kDistributionFixed:
      return 'Ideal ≤10% (fund.+fijo ≤60%)';
    case kDistributionInvestment:
      return 'Ideal 20%';
    case kDistributionLibre:
      return 'Ideal 20%';
    default:
      return '';
  }
}
