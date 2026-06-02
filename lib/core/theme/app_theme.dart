import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.darkBorder,
        surfaceContainerHighest: AppColors.darkCard,
        onSurfaceVariant: AppColors.textSecondaryDark,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
        hintStyle: const TextStyle(color: AppColors.textTertiaryDark),
        prefixIconColor: AppColors.textSecondaryDark,
        suffixIconColor: AppColors.textSecondaryDark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryDark,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardElevated,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.textPrimaryDark),
        displaySmall: AppTextStyles.displaySmall
            .copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: AppTextStyles.headlineLarge
            .copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: AppTextStyles.headlineMedium
            .copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: AppTextStyles.headlineSmall
            .copyWith(color: AppColors.textPrimaryDark),
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.textPrimaryDark),
        titleSmall: AppTextStyles.titleSmall
            .copyWith(color: AppColors.textSecondaryDark),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: AppTextStyles.bodySmall
            .copyWith(color: AppColors.textSecondaryDark),
        labelLarge:
            AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textSecondaryDark),
        labelSmall: AppTextStyles.labelSmall
            .copyWith(color: AppColors.textTertiaryDark),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.lightSurface,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.lightBorder,
        surfaceContainerHighest: AppColors.lightCard,
        onSurfaceVariant: AppColors.textSecondaryLight,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondaryLight),
        hintStyle: const TextStyle(color: AppColors.textTertiaryLight),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.textPrimaryLight),
        displaySmall: AppTextStyles.displaySmall
            .copyWith(color: AppColors.textPrimaryLight),
        headlineLarge: AppTextStyles.headlineLarge
            .copyWith(color: AppColors.textPrimaryLight),
        headlineMedium: AppTextStyles.headlineMedium
            .copyWith(color: AppColors.textPrimaryLight),
        headlineSmall: AppTextStyles.headlineSmall
            .copyWith(color: AppColors.textPrimaryLight),
        titleLarge: AppTextStyles.titleLarge
            .copyWith(color: AppColors.textPrimaryLight),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.textPrimaryLight),
        titleSmall: AppTextStyles.titleSmall
            .copyWith(color: AppColors.textSecondaryLight),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textPrimaryLight),
        bodySmall: AppTextStyles.bodySmall
            .copyWith(color: AppColors.textSecondaryLight),
        labelLarge: AppTextStyles.labelLarge
            .copyWith(color: AppColors.textPrimaryLight),
        labelMedium: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textSecondaryLight),
        labelSmall: AppTextStyles.labelSmall
            .copyWith(color: AppColors.textTertiaryLight),
      ),
    );
  }
}
