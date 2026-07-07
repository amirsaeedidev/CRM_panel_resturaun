import 'package:flutter/material.dart';

abstract class AppRadius {
  // Base radius values
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;
  static const double circular = 999.0;

  // Predefined BorderRadius objects
  static BorderRadius get smallAll => BorderRadius.circular(small);
  static BorderRadius get mediumAll => BorderRadius.circular(medium);
  static BorderRadius get largeAll => BorderRadius.circular(large);
  static BorderRadius get extraLargeAll => BorderRadius.circular(extraLarge);
  static BorderRadius get circularAll => BorderRadius.circular(circular);

  // Asymmetrical radii for specific UI elements
  static BorderRadius get largeTop => const BorderRadius.vertical(
        top: Radius.circular(large),
      );

  static BorderRadius get largeBottom => const BorderRadius.vertical(
        bottom: Radius.circular(large),
      );

  static BorderRadius get mediumTop => const BorderRadius.vertical(
        top: Radius.circular(medium),
      );

  static BorderRadius get mediumBottom => const BorderRadius.vertical(
        bottom: Radius.circular(medium),
      );
}