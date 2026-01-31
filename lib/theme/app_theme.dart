import 'package:flutter/material.dart';

/// Colores de acento vibrantes estilo dashboard moderno
final List<Color> accentColorOptions = [
  const Color(0xFF8B5CF6), // violet vibrante
  const Color(0xFF06B6D4), // cyan
  const Color(0xFF10B981), // emerald
  const Color(0xFFF59E0B), // amber
  const Color(0xFFEC4899), // pink
  const Color(0xFF3B82F6), // blue
  const Color(0xFFEF4444), // red
];

/// Paleta de colores para el tema oscuro moderno
class DashboardColors {
  static const background = Color(0xFF0F0F1E); // Fondo principal oscuro
  static const surface = Color(0xFF1A1A2E); // Superficie de tarjetas
  static const surfaceVariant = Color(0xFF252538); // Superficie alternativa
  static const primary = Color(0xFF8B5CF6); // Púrpura vibrante
  static const secondary = Color(0xFF06B6D4); // Cyan
  static const accent1 = Color(0xFF10B981); // Verde
  static const accent2 = Color(0xFFF59E0B); // Amarillo/naranja
  static const accent3 = Color(0xFFEC4899); // Rosa
  static const textPrimary = Color(0xFFFFFFFF); // Texto principal
  static const textSecondary = Color(0xFF94A3B8); // Texto secundario
  static const border = Color(0xFF2D2D44); // Bordes sutiles
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
}

ThemeData buildAppTheme({
  required Brightness brightness,
  required Color seedColor,
}) {
  final isDark = brightness == Brightness.dark;
  
  if (isDark) {
    // Tema oscuro moderno estilo dashboard
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DashboardColors.background,
      colorScheme: ColorScheme.dark(
        primary: seedColor,
        secondary: DashboardColors.secondary,
        surface: DashboardColors.surface,
        surfaceContainerHighest: DashboardColors.surfaceVariant,
        background: DashboardColors.background,
        error: DashboardColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: DashboardColors.textPrimary,
        onSurfaceVariant: DashboardColors.textSecondary,
        onBackground: DashboardColors.textPrimary,
        outline: DashboardColors.border,
      ),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: DashboardColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: DashboardColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: DashboardColors.textPrimary,
          letterSpacing: -0.3,
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
        titleSmall: TextStyle(
          fontSize: 14,
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
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: DashboardColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: DashboardColors.background,
        foregroundColor: DashboardColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: DashboardColors.textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: DashboardColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: DashboardColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DashboardColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DashboardColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: DashboardColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(color: DashboardColors.textSecondary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        backgroundColor: seedColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DashboardColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: DashboardColors.border,
        thickness: 1,
        space: 1,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: DashboardColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        textColor: DashboardColors.textPrimary,
        iconColor: DashboardColors.textSecondary,
        selectedColor: seedColor,
        selectedTileColor: seedColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: DashboardColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
      ),
    );
  }
  
  // Tema claro (fallback)
  final scheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

/// Convierte el nombre del icono guardado en categoría a IconData.
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
