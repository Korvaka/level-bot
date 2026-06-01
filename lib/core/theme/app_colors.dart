import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3D35CC);

  // Secondary
  static const Color secondary = Color(0xFF00D4AA);
  static const Color secondaryLight = Color(0xFF4DFFDB);
  static const Color secondaryDark = Color(0xFF009975);

  // Accent
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentYellow = Color(0xFFFFD700);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0E0E0F);
  static const Color darkSurface = Color(0xFF1A1A1D);
  static const Color darkCard = Color(0xFF242428);
  static const Color darkCardElevated = Color(0xFF2E2E33);
  static const Color darkBorder = Color(0xFF3A3A40);
  static const Color darkDivider = Color(0xFF2A2A2F);

  // Light Theme
  static const Color lightBackground = Color(0xFFF8F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0F8);
  static const Color lightBorder = Color(0xFFE0E0F0);
  static const Color lightDivider = Color(0xFFEEEEF8);

  // Text - Dark
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0C0);
  static const Color textTertiaryDark = Color(0xFF707080);

  // Text - Light
  static const Color textPrimaryLight = Color(0xFF0E0E1A);
  static const Color textSecondaryLight = Color(0xFF5A5A70);
  static const Color textTertiaryLight = Color(0xFFA0A0B0);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Muscle Groups
  static const Color chest = Color(0xFFFF6B6B);
  static const Color back = Color(0xFF4ECDC4);
  static const Color shoulders = Color(0xFF45B7D1);
  static const Color biceps = Color(0xFF96CEB4);
  static const Color triceps = Color(0xFFFFEAA7);
  static const Color forearms = Color(0xFFDDA0DD);
  static const Color abs = Color(0xFFFF8C42);
  static const Color quads = Color(0xFF6C63FF);
  static const Color hamstrings = Color(0xFF00D4AA);
  static const Color glutes = Color(0xFFFF69B4);
  static const Color calves = Color(0xFF87CEEB);
  static const Color cardio = Color(0xFFFF4757);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF9C63FF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, darkSurface],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E22), Color(0xFF2A2A30)],
  );
}
