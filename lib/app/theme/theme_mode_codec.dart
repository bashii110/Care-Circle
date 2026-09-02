import 'package:flutter/material.dart';

/// Converts between the plain `'system' | 'light' | 'dark'` string
/// [PreferencesService] persists and Flutter's [ThemeMode] enum.
///
/// Kept out of `PreferencesService` itself so that service stays free of a
/// Flutter framework dependency (see its doc comment) — this is the one
/// place that bridges "storage string" and "UI enum".
ThemeMode themeModeFromStorageValue(String value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

String themeModeToStorageValue(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}
