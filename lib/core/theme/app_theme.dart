import 'package:flutter/material.dart';

abstract class AppTypography {
  static const String fontFamily = 'Lalezar';

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57.0,
        fontWeight: FontWeight.w400,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 45.0,
        fontWeight: FontWeight.w400,
        height: 1.2,
        letterSpacing: -0.25,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36.0,
        fontWeight: FontWeight.w400,
        height: 1.25,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.0,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28.0,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.65,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.5,
      ),
    );
  }
}