import 'dart:io';

import 'package:care_circle/data/repositories/vital_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/adapters/hive_adapters.dart';
import 'package:care_circle/data/models/care_models.dart';


void main() {
  late Directory tempDir;
  late Box<HealthVital> box;
  late HiveVitalRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('care_circle_test_');
    Hive.init(tempDir.path);
    registerHiveAdapters();
    box = await Hive.openBox<HealthVital>('vitalsBox_test');
    repository = HiveVitalRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('add persists a blood pressure reading', () async {
    await repository.add(HealthVital(
      id: '1',
      timestamp: DateTime(2026, 8, 30, 8),
      vitalType: VitalTypes.bloodPressure,
      primaryValue: 120,
      secondaryValue: 80,
    ));
    expect(repository.getAll(), hasLength(1));
  });

  test('add rejects an unknown vital type', () {
    final HealthVital bad = HealthVital(
      id: '1',
      timestamp: DateTime.now(),
      vitalType: 'cholesterol',
      primaryValue: 1,
    );
    expect(() => repository.add(bad), throwsA(isA<ValidationFailure>()));
  });

  test('add rejects a non-positive value', () {
    final HealthVital bad = HealthVital(
      id: '1',
      timestamp: DateTime.now(),
      vitalType: VitalTypes.weight,
      primaryValue: 0,
    );
    expect(() => repository.add(bad), throwsA(isA<ValidationFailure>()));
  });
}