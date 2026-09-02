import 'package:flutter/material.dart';

/// Builds the app [TextTheme] from the hierarchy in design.md §4.
///
/// Design.md's sizes are mapped onto Material 3 type roles as follows:
///
/// | design.md element | size  | M3 role         |
/// |--------------------|-------|-----------------|
/// | Display heading    | 34    | displayMedium   |
/// | Screen title        | 26    | headlineMedium  |
/// | Section heading      | 21    | titleLarge      |
/// | Body                | 17    | bodyLarge       |
/// | Supporting text      | 15    | bodyMedium      |
/// | Button text         | 17    | labelLarge      |
///
/// Font weights stay at or above [FontWeight.w400] throughout — design.md
/// explicitly calls out avoiding ultra-light weights for readability.
TextTheme buildAppTextTheme(ColorScheme colorScheme) {
  final Color onSurface = colorScheme.onSurface;
  final Color onSurfaceVariant = colorScheme.onSurfaceVariant;

  return TextTheme(
    displayMedium: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w600,
      color: onSurface,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: onSurface,
      height: 1.25,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w600,
      color: onSurface,
      height: 1.3,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: onSurface,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: onSurfaceVariant,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: onSurface,
      height: 1.2,
    ),
  );
}
