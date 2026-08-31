import 'package:flutter/material.dart';

/// Seed color for the Material 3 [ColorScheme] (design.md §3 —
/// "Primary: Deep accessible blue").
///
/// The full palette is generated from this seed via [ColorScheme.fromSeed]
/// rather than hard-coded throughout the UI, per design.md §3. Exact
/// contrast validation against WCAG happens during Phase 9
/// (Accessibility & UX Hardening).
const Color kSeedColor = Color(0xFF0B5FA5);

/// Status colors that fall outside Material 3's default [ColorScheme]
/// roles (success/warning have no standard M3 slot).
///
/// This is intentionally a [ThemeExtension] — not a set of static
/// constants — so status colors still flow through `Theme.of(context)`
/// and automatically adapt for light mode, dark mode, and the future
/// high-contrast mode (design.md §3, §15), instead of being hard-coded
/// at call sites.
///
/// Usage: `Theme.of(context).extension<CareStatusColors>()!.success`
@immutable
class CareStatusColors extends ThemeExtension<CareStatusColors> {
  const CareStatusColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;

  static const CareStatusColors light = CareStatusColors(
    success: Color(0xFF1E7D34),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFF9A6400),
    onWarning: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
  );

  static const CareStatusColors dark = CareStatusColors(
    success: Color(0xFF7DDB8E),
    onSuccess: Color(0xFF00390E),
    warning: Color(0xFFFFC26B),
    onWarning: Color(0xFF3F2900),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
  );

  @override
  CareStatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? error,
    Color? onError,
  }) {
    return CareStatusColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      error: error ?? this.error,
      onError: onError ?? this.onError,
    );
  }

  @override
  CareStatusColors lerp(ThemeExtension<CareStatusColors>? other, double t) {
    if (other is! CareStatusColors) return this;
    return CareStatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }
}
