import 'package:care_circle/core/services/preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late PreferencesService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    service = PreferencesService(await SharedPreferences.getInstance());
  });

  test('defaults are safe for a first launch', () {
    expect(service.onboardingCompleted, isFalse);
    expect(service.themeMode, 'system');
    expect(service.highContrastEnabled, isFalse);
    expect(service.selectedProfileId, isNull);
  });

  test('onboardingCompleted round-trips', () async {
    await service.setOnboardingCompleted(true);
    expect(service.onboardingCompleted, isTrue);
  });

  test('selectedProfileId can be set and cleared', () async {
    await service.setSelectedProfileId('senior-1');
    expect(service.selectedProfileId, 'senior-1');

    await service.setSelectedProfileId(null);
    expect(service.selectedProfileId, isNull);
  });

  test('highContrastEnabled round-trips', () async {
    await service.setHighContrastEnabled(true);
    expect(service.highContrastEnabled, isTrue);
  });
}
