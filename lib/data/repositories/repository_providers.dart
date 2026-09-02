import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'incident_repository.dart';
import 'medication_repository.dart';
import 'profile_repository.dart';
import 'vitals_repository.dart';

// ---------------------------------------------------------------------------
// architecture.md §6 lists these as the four repository providers. Each one
// throws by default — exactly like `preferencesServiceProvider` in
// `app/app.dart` — so a missing override in `main.dart` (or a test) fails
// loudly at the point of use instead of silently returning a
// not-yet-initialized repository. `main.dart` overrides all four with real
// `Hive*Repository` instances once `HiveStorageService.instance.init()`
// has opened the corresponding boxes.
// ---------------------------------------------------------------------------

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>((ref) {
  throw UnimplementedError(
    'profileRepositoryProvider must be overridden before the app is run.',
  );
});

final Provider<MedicationRepository> medicationRepositoryProvider =
    Provider<MedicationRepository>((ref) {
  throw UnimplementedError(
    'medicationRepositoryProvider must be overridden before the app is run.',
  );
});

final Provider<VitalsRepository> vitalsRepositoryProvider =
    Provider<VitalsRepository>((ref) {
  throw UnimplementedError(
    'vitalsRepositoryProvider must be overridden before the app is run.',
  );
});

final Provider<IncidentRepository> incidentRepositoryProvider =
    Provider<IncidentRepository>((ref) {
  throw UnimplementedError(
    'incidentRepositoryProvider must be overridden before the app is run.',
  );
});
