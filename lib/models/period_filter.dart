/// Tipos de período para filtrar reportes
enum PeriodType {
  currentMonth,      // Mes actual (default)
  lastThreeMonths,   // Últimos 3 meses
  specificMonth,     // Mes específico (año + mes)
  yearToDate,        // Año en curso (hasta hoy)
  fullYear,          // Año completo
}

/// Filtro de período para reportes y dashboard
class PeriodFilter {
  final PeriodType type;
  final int year;
  final int? month; // null para reportes anuales

  const PeriodFilter({
    required this.type,
    required this.year,
    this.month,
  });

  /// Período por defecto: mes actual
  factory PeriodFilter.currentMonth() {
    final now = DateTime.now();
    return PeriodFilter(
      type: PeriodType.currentMonth,
      year: now.year,
      month: now.month,
    );
  }

  /// Últimos 3 meses
  factory PeriodFilter.lastThreeMonths() {
    final now = DateTime.now();
    return PeriodFilter(
      type: PeriodType.lastThreeMonths,
      year: now.year,
      month: now.month,
    );
  }

  /// Mes específico
  factory PeriodFilter.specificMonth(int year, int month) {
    return PeriodFilter(
      type: PeriodType.specificMonth,
      year: year,
      month: month,
    );
  }

  /// Año en curso (hasta la fecha actual)
  factory PeriodFilter.yearToDate(int year) {
    return PeriodFilter(
      type: PeriodType.yearToDate,
      year: year,
    );
  }

  /// Año completo
  factory PeriodFilter.fullYear(int year) {
    return PeriodFilter(
      type: PeriodType.fullYear,
      year: year,
    );
  }

  /// Obtiene el rango de fechas según el tipo de período
  (DateTime from, DateTime to) getDateRange() {
    final now = DateTime.now();
    
    switch (type) {
      case PeriodType.currentMonth:
        final from = DateTime(year, month!, 1);
        final to = DateTime(year, month! + 1, 0, 23, 59, 59);
        return (from, to);
        
      case PeriodType.lastThreeMonths:
        // Calcula 3 meses atrás
        DateTime threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
        final to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (threeMonthsAgo, to);
        
      case PeriodType.specificMonth:
        final from = DateTime(year, month!, 1);
        final to = DateTime(year, month! + 1, 0, 23, 59, 59);
        return (from, to);
        
      case PeriodType.yearToDate:
        final from = DateTime(year, 1, 1);
        // Si es el año actual, hasta hoy; si no, hasta fin de año
        final to = year == now.year 
            ? DateTime(now.year, now.month, now.day, 23, 59, 59)
            : DateTime(year, 12, 31, 23, 59, 59);
        return (from, to);
        
      case PeriodType.fullYear:
        final from = DateTime(year, 1, 1);
        final to = DateTime(year, 12, 31, 23, 59, 59);
        return (from, to);
    }
  }

  /// Nombre legible del período
  String get displayName {
    switch (type) {
      case PeriodType.currentMonth:
        return 'Mes actual';
      case PeriodType.lastThreeMonths:
        return 'Últimos 3 meses';
      case PeriodType.specificMonth:
        return '${_monthName(month!)} $year';
      case PeriodType.yearToDate:
        return 'Año $year (hasta hoy)';
      case PeriodType.fullYear:
        return 'Todo $year';
    }
  }

  /// Descripción corta del período
  String get shortDescription {
    final (from, to) = getDateRange();
    switch (type) {
      case PeriodType.currentMonth:
      case PeriodType.specificMonth:
        return '${_monthName(month!)} $year';
      case PeriodType.lastThreeMonths:
        return '${_shortMonth(from.month)} - ${_shortMonth(to.month)} ${to.year}';
      case PeriodType.yearToDate:
        return 'Ene - ${_shortMonth(to.month)} $year';
      case PeriodType.fullYear:
        return 'Ene - Dic $year';
    }
  }

  static String _monthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month.clamp(1, 12)];
  }

  static String _shortMonth(int month) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return months[month.clamp(1, 12)];
  }

  /// Lista de años disponibles (desde 2020 hasta el actual + 1)
  static List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 2019, (i) => currentYear - i);
  }

  /// Lista de meses
  static List<({int value, String name})> get months {
    return List.generate(12, (i) => (
      value: i + 1,
      name: _monthName(i + 1),
    ));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodFilter &&
        other.type == type &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode => Object.hash(type, year, month);
}
