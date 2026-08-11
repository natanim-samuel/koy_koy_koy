import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Builds the app's light and dark [ThemeData].
///
/// "Light" here means the app's default (white-canvas-for-data-screens)
/// theme, and "dark" means the deep teal canvas used for forms — this is
/// the same toggle shown in Settings > Dark Mode, not a generic Material
/// light/dark split.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _base(
    brightness: Brightness.light,
    scaffoldBg: AppColors.lightBg,
    surface: AppColors.lightBg,
    onSurface: AppColors.textOnLight,
    onSurfaceSecondary: AppColors.textOnLightSecondary,
    primary: AppColors.lightCard,
  );

  static ThemeData get dark => _base(
    brightness: Brightness.dark,
    scaffoldBg: AppColors.bg,
    surface: AppColors.card,
    onSurface: AppColors.textOnDark,
    onSurfaceSecondary: AppColors.textOnDarkSecondary,
    primary: AppColors.mint,
  );

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surface,
    required Color onSurface,
    required Color onSurfaceSecondary,
    required Color primary,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: primary,
        onPrimary: AppColors.bgDeep,
        surface: surface,
        onSurface: onSurface,
        error: AppColors.coral,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.dark ? AppColors.card : AppColors.lightBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.bgDeep,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark ? AppColors.card : AppColors.trackGray.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: onSurfaceSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgDeep,
        selectedItemColor: AppColors.mint,
        unselectedItemColor: AppColors.textOnDarkMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      dividerColor: onSurfaceSecondary.withValues(alpha: 0.15),
    );
  }
}