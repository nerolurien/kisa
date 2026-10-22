import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class KisaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: KisaColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: KisaColors.primaryRose,
        onPrimary: Colors.white,
        secondary: KisaColors.peach,
        onSecondary: Colors.white,
        error: Color(0xFFE11D48),
        onError: Colors.white,
        surface: KisaColors.surface,
        onSurface: KisaColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      dividerTheme: const DividerThemeData(
        color: KisaColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: KisaColors.surfaceGlass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: KisaColors.borderSubtle, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        modalBackgroundColor: Colors.transparent,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        backgroundColor: KisaColors.primaryRose,
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: KisaColors.surfaceGlass,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: KisaTypography.displayLarge,
        displayMedium: KisaTypography.displayMedium,
        titleLarge: KisaTypography.titleLarge,
        titleMedium: KisaTypography.titleMedium,
        bodyLarge: KisaTypography.bodyLarge,
        bodyMedium: KisaTypography.bodyMedium,
        labelSmall: KisaTypography.labelSmall,
      ),
    );
  }
}
