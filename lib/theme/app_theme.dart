import 'package:flutter/material.dart';

final List<Color> accentColorOptions = [
  const Color(0xFF8B5CF6),
  const Color(0xFF06B6D4),
  const Color(0xFF10B981),
  const Color(0xFFF59E0B),
  const Color(0xFFEC4899),
  const Color(0xFF3B82F6),
  const Color(0xFFEF4444),
];

class DashboardColors {
  static const background = Color(0xFF0A0E1A);
  static const surface = Color(0xFF141824);
  static const surfaceVariant = Color(0xFF1A1F2E);
  static const border = Color.fromRGBO(255, 255, 255, 0.1);
  static const primary = Color(0xFF00D9FF);
  static const accent = Color(0xFF7C3AED);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFE4E7F0);
  static const textSecondary = Color(0xFF9CA3AF);
}

ThemeData buildAppTheme({
  required Brightness brightness,
  required Color seedColor,
}) {
  final isDark = brightness == Brightness.dark;
  if (isDark) {
    final scheme = ColorScheme.dark(
      primary: seedColor,
      onPrimary: const Color(0xFF0A0E1A),
      secondary: DashboardColors.surfaceVariant,
      onSecondary: DashboardColors.textPrimary,
      error: DashboardColors.error,
      onError: Colors.white,
      surface: DashboardColors.surface,
      onSurface: DashboardColors.textPrimary,
      surfaceContainerHighest: DashboardColors.surfaceVariant,
      onSurfaceVariant: DashboardColors.textSecondary,
      outline: DashboardColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: DashboardColors.background,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: DashboardColors.background,
        foregroundColor: DashboardColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: DashboardColors.textPrimary,
        ),
      ),
      textTheme: const TextTheme(
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: DashboardColors.textPrimary,
          letterSpacing: -0.6,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: DashboardColors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DashboardColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: DashboardColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: DashboardColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: DashboardColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: DashboardColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: DashboardColors.surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DashboardColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: DashboardColors.border,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        textColor: DashboardColors.textPrimary,
        iconColor: DashboardColors.textSecondary,
        selectedTileColor: const Color(0xFF00D9FF).withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DashboardColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DashboardColors.surfaceVariant,
        hintStyle: const TextStyle(color: DashboardColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DashboardColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DashboardColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seedColor, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: seedColor,
          foregroundColor: const Color(0xFF0A0E1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: seedColor,
        foregroundColor: const Color(0xFF0A0E1A),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  final scheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

IconData iconDataFromName(String name) {
  const map = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'shopping_cart': Icons.shopping_cart,
    'category': Icons.category,
    'flight': Icons.flight,
    'school': Icons.school,
    'savings': Icons.savings,
    'payments': Icons.payments,
    'attach_money': Icons.attach_money,
    'pets': Icons.pets,
    'sports_esports': Icons.sports_esports,
  };
  return map[name] ?? Icons.category;
}
