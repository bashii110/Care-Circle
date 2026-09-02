import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

part 'care_models.g.dart';

// ---------------------------------------------------------------------------
// These models are intentionally plain Dart classes with Hive annotations —
// not `extends HiveObject` — so persistence stays entirely behind the
// repository layer (architecture.md §3). Widgets and even domain logic
// never call `.save()`/`.delete()` on these objects directly.
//
// Lists and maps passed into constructors are defensively copied into
// unmodifiable views, so a caller can't mutate a model's internals after
// construction and accidentally desync it from what's persisted.
// ---------------------------------------------------------------------------

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final K key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}

/// A senior being cared for (srd.md §4 — `SeniorProfile`).
@HiveType(typeId: HiveTypeIds.seniorProfile)
class SeniorProfile {
  SeniorProfile({
    required this.id,
    required this.fullName,
    required this.age,
    this.primaryCondition,
    required this.emergencyContactPhone,
    this.bloodType,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final String? primaryCondition;

  @HiveField(4)
  final String emergencyContactPhone;

  @HiveField(5)
  final String? bloodType;

  SeniorProfile copyWith({
    String? fullName,
    int? age,
    String? primaryCondition,
    String? emergencyContactPhone,
    String? bloodType,
  }) {
    return SeniorProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      primaryCondition: primaryCondition ?? this.primaryCondition,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      bloodType: bloodType ?? this.bloodType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeniorProfile &&
        other.id == id &&
        other.fullName == fullName &&
        other.age == age &&
        other.primaryCondition == primaryCondition &&
        other.emergencyContactPhone == emergencyContactPhone &&
        other.bloodType == bloodType;
  }

  @override
  int get hashCode =>
      Object.hash(id, fullName, age, primaryCondition, emergencyContactPhone, bloodType);

  @override
  String toString() => 'SeniorProfile(id: $id, fullName: $fullName)';
}

/// A scheduled medication (srd.md §4 — `Medication`).
///
/// [complianceHistory] maps an ISO-8601 date+time key for a scheduled dose
/// to whether it was taken (`true`) or explicitly skipped (`false`). A
/// dedicated `MedicationEvent` model is the recommended production
/// evolution of this (srd.md §4's "Recommended schema improvement"), but
/// is deliberately deferred — introducing it now, before Phase 3's
/// medication engine or Phase 5's dashboard timeline exist to consume it,
/// would be building ahead of the phase that needs it.
@HiveType(typeId: HiveTypeIds.medication)
class Medication {
  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    this.instructions,
    required List<int> alarmHours,
    required List<int> alarmMinutes,
    Map<String, bool> complianceHistory = const <String, bool>{},
  })  : alarmHours = List.unmodifiable(alarmHours),
        alarmMinutes = List.unmodifiable(alarmMinutes),
        complianceHistory = Map.unmodifiable(complianceHistory);

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final String? instructions;

  @HiveField(4)
  final List<int> alarmHours;

  @HiveField(5)
  final List<int> alarmMinutes;

  @HiveField(6)
  final Map<String, bool> complianceHistory;

  Medication copyWith({
    String? name,
    String? dosage,
    String? instructions,
    List<int>? alarmHours,
    List<int>? alarmMinutes,
    Map<String, bool>? complianceHistory,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      alarmHours: alarmHours ?? this.alarmHours,
      alarmMinutes: alarmMinutes ?? this.alarmMinutes,
      complianceHistory: complianceHistory ?? this.complianceHistory,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Medication &&
        other.id == id &&
        other.name == name &&
        other.dosage == dosage &&
        other.instructions == instructions &&
        _listEquals(other.alarmHours, alarmHours) &&
        _listEquals(other.alarmMinutes, alarmMinutes) &&
        _mapEquals(other.complianceHistory, complianceHistory);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        dosage,
        instructions,
        Object.hashAll(alarmHours),
        Object.hashAll(alarmMinutes),
      );

  @override
  String toString() => 'Medication(id: $id, name: $name, dosage: $dosage)';
}

/// The kind of measurement a [HealthVital] records (srd.md §6).
///
/// This is a plain Dart enum, not a `@HiveType` enum — [HealthVital]
/// persists it as the plain [String] the schema in srd.md §4 specifies
/// (via [storageValue]), so no additional generated adapter is needed for
/// it. This still gives call sites compile-time safety when constructing
/// or branching on a vital's type.
enum VitalType {
  bloodPressure('blood_pressure'),
  glucose('glucose'),
  weight('weight'),
  heartRate('heart_rate');

  const VitalType(this.storageValue);

  /// The exact string persisted in [HealthVital.vitalType].
  final String storageValue;

  static VitalType? fromStorageValue(String value) {
    for (final VitalType type in VitalType.values) {
      if (type.storageValue == value) return type;
    }
    return null;
  }
}

/// A single health measurement (srd.md §4 — `HealthVital`).
@HiveType(typeId: HiveTypeIds.healthVital)
class HealthVital {
  HealthVital({
    required this.id,
    required this.timestamp,
    required this.vitalType,
    required this.primaryValue,
    this.secondaryValue,
    this.notes,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  /// Persisted form of a [VitalType] — see [VitalType.storageValue].
  @HiveField(2)
  final String vitalType;

  @HiveField(3)
  final double primaryValue;

  @HiveField(4)
  final double? secondaryValue;

  @HiveField(5)
  final String? notes;

  HealthVital copyWith({
    DateTime? timestamp,
    String? vitalType,
    double? primaryValue,
    double? secondaryValue,
    String? notes,
  }) {
    return HealthVital(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      vitalType: vitalType ?? this.vitalType,
      primaryValue: primaryValue ?? this.primaryValue,
      secondaryValue: secondaryValue ?? this.secondaryValue,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HealthVital &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.vitalType == vitalType &&
        other.primaryValue == primaryValue &&
        other.secondaryValue == secondaryValue &&
        other.notes == notes;
  }

  @override
  int get hashCode =>
      Object.hash(id, timestamp, vitalType, primaryValue, secondaryValue, notes);

  @override
  String toString() => 'HealthVital(id: $id, vitalType: $vitalType, at: $timestamp)';
}

/// The severity of an [IncidentLog] (srd.md §7).
///
/// Like [VitalType], this is a plain enum persisted as a [String] — see
/// [storageValue] — rather than a second `@HiveType` enum.
enum IncidentSeverity {
  low('low'),
  medium('medium'),
  high('high');

  const IncidentSeverity(this.storageValue);

  final String storageValue;

  static IncidentSeverity? fromStorageValue(String value) {
    for (final IncidentSeverity severity in IncidentSeverity.values) {
      if (severity.storageValue == value) return severity;
    }
    return null;
  }
}

/// A behavioral/event record (srd.md §4 — `IncidentLog`).
@HiveType(typeId: HiveTypeIds.incidentLog)
class IncidentLog {
  IncidentLog({
    required this.id,
    required this.timestamp,
    required this.severity,
    this.behaviorTags = '',
    this.detailedDescription = '',
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  /// Persisted form of an [IncidentSeverity] — see
  /// [IncidentSeverity.storageValue].
  @HiveField(2)
  final String severity;

  /// Comma-separated behavior tags (e.g. "Confusion,Fall / Slip"), matching
  /// the `String` type in srd.md §4's schema table.
  @HiveField(3)
  final String behaviorTags;

  @HiveField(4)
  final String detailedDescription;

  /// Convenience view of [behaviorTags] split into a trimmed, non-empty list.
  List<String> get behaviorTagList => behaviorTags
      .split(',')
      .map((String tag) => tag.trim())
      .where((String tag) => tag.isNotEmpty)
      .toList(growable: false);

  IncidentLog copyWith({
    DateTime? timestamp,
    String? severity,
    String? behaviorTags,
    String? detailedDescription,
  }) {
    return IncidentLog(
      id: id,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      behaviorTags: behaviorTags ?? this.behaviorTags,
      detailedDescription: detailedDescription ?? this.detailedDescription,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IncidentLog &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.severity == severity &&
        other.behaviorTags == behaviorTags &&
        other.detailedDescription == detailedDescription;
  }

  @override
  int get hashCode =>
      Object.hash(id, timestamp, severity, behaviorTags, detailedDescription);

  @override
  String toString() => 'IncidentLog(id: $id, severity: $severity, at: $timestamp)';
}
