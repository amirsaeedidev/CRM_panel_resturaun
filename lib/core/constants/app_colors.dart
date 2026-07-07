import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFB71C1C); // Luxury Red / Deep Crimson
  static const Color primaryLight = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFF7F0000);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Background Colors
  static const Color background = Color(0xFF0A0A0A); // Dark Background
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFF141414); // Graphite Surface
  static const Color surfaceLight = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF242424);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0); // Grey Text

  // Semantic & Status Colors
  static const Color success = Color(0xFF00C853); // Green Success
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFFFAB00); // Amber Warning
  static const Color onWarning = Color(0xFF000000);
  static const Color info = Color(0xFF2962FF); // Blue Info
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F); // Material Error
  static const Color onError = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textDarkGrey = Color(0xFF616161);

  // Border Colors
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderLight = Color(0xFF3D3D3D);

  // Chart Colors
  static const Color chartPrimary = Color(0xFFE53935);
  static const Color chartSecondary = Color(0xFF1E88E5);
  static const Color chartTertiary = Color(0xFF43A047);
  static const Color chartQuaternary = Color(0xFFFB8C00);
  static const Color chartQuinary = Color(0xFF8E24AA);

  // Gradient Colors
  static const Color gradientStart = Color(0xFFB71C1C);
  static const Color gradientEnd = Color(0xFFE53935);
  static const Color gradientSuccessStart = Color(0xFF00C853);
  static const Color gradientSuccessEnd = Color(0xFF009624);
  static const Color gradientDangerStart = Color(0xFFD32F2F);
  static const Color gradientDangerEnd = Color(0xFFB71C1C);

  // Opacity Colors (For glass feeling without transparency abuse)
  static const Color primaryOpacity10 = Color(0x1AB71C1C);
  static const Color primaryOpacity20 = Color(0x33B71C1C);
  static const Color whiteOpacity5 = Color(0x0DFFFFFF);
  static const Color whiteOpacity10 = Color(0x1AFFFFFF);
  static const Color whiteOpacity20 = Color(0x33FFFFFF);
}