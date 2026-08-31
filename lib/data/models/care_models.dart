/// Domain models for CareCircle's local-first data layer (phases.md
/// "Phase 1 — Data Layer"; srd.md §4 "Data Requirements").
///
/// Hive type IDs are assigned once and must never be reused or
/// renumbered after release (architecture.md §5, §16). Type ID 4 is
/// reserved for a future `MedicationEvent` model (architecture.md §5's
/// "Recommended IDs"; srd.md §4's "Recommended schema improvement") and
/// must not be assigned to anything else in the meantime.
library;

import 'package:hive/hive.dart';

part 'care_models.g.dart';

/// Allowed values for [HealthVital.vitalType] (srd.md §3 FR-06).
abstract final class VitalTypes {
  static const String bloodPressure = 'bloodPressure';
  static const String glucose = 'glucose';
  static const String weight = 'weight';
  static const String heartRate = 'heartRate';

  static const Set<String> all = <String>{
    bloodPressure,
    glucose,
    weight,
    heartRate,
  };
}

/// Allowed values for [IncidentLog.severity] (design.md §10).
abstract final class IncidentSeverity {
  static const String low = 'low';
  static const String medium = 'medium';
  static const String high = 'high';

  static const Set<String> all = <String>{low, medium, high};
}

@HiveType(typeId: 0)
class SeniorProfile extends HiveObject {
  SeniorProfile({
    required this.id,
    required this.fullName,
    required this.age,
    this.primaryCondition,
    required this.emergencyContactPhone,
    this.bloodType,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  int age;

  @HiveField(3)
  String? primaryCondition;

  @HiveField(4)
  String emergencyContactPhone;

  @HiveField(5)
  String? bloodType;

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
}

@HiveType(typeId: 1)
class Medication extends HiveObject {
  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    this.instructions,
    required this.alarmHours,
    required this.alarmMinutes,
    Map<String, bool>? complianceHistory,
  }) : complianceHistory = complianceHistory ?? <String, bool>{};

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String dosage;

  @HiveField(3)
  String? instructions;

  @HiveField(4)
  List<int> alarmHours;

  @HiveField(5)
  List<int> alarmMinutes;

  /// Keyed by an event identifier (e.g. an ISO date+time slot); srd.md §4
  /// flags this as a schema that should become a dedicated
  /// `MedicationEvent` model (type ID 4) once event history/audit needs
  /// grow — deliberately deferred past Phase 1.
  @HiveField(6)
  Map<String, bool> complianceHistory;

  Medication copyWith({
    String? name,
    String? dosage,
    String? instructions,
    List<int>? alarmHours,
    List<int>? alarmMinutes,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      alarmHours: alarmHours ?? this.alarmHours,
      alarmMinutes: alarmMinutes ?? this.alarmMinutes,
      complianceHistory: complianceHistory,
    );
  }
}

@HiveType(typeId: 2)
class HealthVital extends HiveObject {
  HealthVital({
    required this.id,
    required this.timestamp,
    required this.vitalType,
    required this.primaryValue,
    this.secondaryValue,
    this.notes = '',
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String vitalType;

  @HiveField(3)
  double primaryValue;

  /// e.g. diastolic reading when [vitalType] is [VitalTypes.bloodPressure].
  @HiveField(4)
  double? secondaryValue;

  @HiveField(5)
  String notes;
}

@HiveType(typeId: 3)
class IncidentLog extends HiveObject {
  IncidentLog({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.behaviorTags,
    this.detailedDescription = '',
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String severity;

  @HiveField(3)
  String behaviorTags;

  @HiveField(4)
  String detailedDescription;
}