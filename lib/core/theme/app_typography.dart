import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Lalezar';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.22,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.33,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    height: 1.33,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    height: 1.43,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: _fontFamily,
    height: 1.33,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    height: 1.45,
  );

  // Helper method to apply font family to the whole theme
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}