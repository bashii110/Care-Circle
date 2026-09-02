import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Thin, typed wrapper around [SharedPreferences].
///
/// Per architecture.md §4, this must only ever be used for small,
/// non-sensitive configuration (onboarding state, theme, high-contrast
/// flag, selected profile id) — never medical records or secrets.
///
/// A concrete [SharedPreferences] instance is obtained once at startup
/// (see `main.dart`) and injected into this service, which is then
/// exposed to the widget tree via a Riverpod provider
/// ([preferencesServiceProvider] in `app/app.dart`). This keeps Hive/
/// SharedPreferences access out of widgets entirely, matching the
/// dependency direction in architecture.md §3.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  bool get onboardingCompleted =>
      _prefs.getBool(PreferenceKeys.onboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(PreferenceKeys.onboardingCompleted, value);

  /// One of: 'system', 'light', 'dark'. Defaults to 'system'.
  String get themeMode => _prefs.getString(PreferenceKeys.themeMode) ?? 'system';

  Future<void> setThemeMode(String value) =>
      _prefs.setString(PreferenceKeys.themeMode, value);

  bool get highContrastEnabled =>
      _prefs.getBool(PreferenceKeys.highContrastEnabled) ?? false;

  Future<void> setHighContrastEnabled(bool value) =>
      _prefs.setBool(PreferenceKeys.highContrastEnabled, value);

  String? get selectedProfileId =>
      _prefs.getString(PreferenceKeys.selectedProfileId);

  Future<void> setSelectedProfileId(String? id) {
    if (id == null) {
      return _prefs.remove(PreferenceKeys.selectedProfileId);
    }
    return _prefs.setString(PreferenceKeys.selectedProfileId, id);
  }
}
