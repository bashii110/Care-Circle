import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/incident_repositories.dart';
import '../data/repositories/medication_repositories.dart';
import '../data/repositories/profile_repositories.dart';
import '../data/repositories/vital_repositories.dart';



/// Repository providers (architecture.md §6). No default implementation —
/// same pattern as `preferencesServiceProvider` in `app/app.dart` — so a
/// missing override fails loudly instead of silently touching disk.
/// `main.dart` overrides all four with `Hive*Repository` instances backed
/// by the boxes opened in `HiveStorageService.init()`.
///
/// Feature notifiers that consume these arrive in their own phases
/// (Phase 2/3/6/7), once there are screens to back.
final Provider<ProfileRepository> profileRepositoryProvider =
Provider<ProfileRepository>((ref) {
  throw UnimplementedError(
    'profileRepositoryProvider must be overridden before the app is run '
        '(see main.dart).',
  );
});

final Provider<MedicationRepository> medicationRepositoryProvider =
Provider<MedicationRepository>((ref) {
  throw UnimplementedError(
    'medicationRepositoryProvider must be overridden before the app is '
        'run (see main.dart).',
  );
});

final Provider<VitalRepository> vitalRepositoryProvider =
Provider<VitalRepository>((ref) {
  throw UnimplementedError(
    'vitalRepositoryProvider must be overridden before the app is run '
        '(see main.dart).',
  );
});

final Provider<IncidentRepository> incidentRepositoryProvider =
Provider<IncidentRepository>((ref) {
  throw UnimplementedError(
    'incidentRepositoryProvider must be overridden before the app is run '
        '(see main.dart).',
  );
});