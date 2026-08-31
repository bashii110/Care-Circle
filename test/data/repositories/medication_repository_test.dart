import 'dart:io';

import 'package:care_circle/data/repositories/medication_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/adapters/hive_adapters.dart';
import 'package:care_circle/data/models/care_models.dart';


void main() {
  late Directory tempDir;
  late Box<Medication> box;
  late HiveMedicationRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('care_circle_test_');
    Hive.init(tempDir.path);
    registerHiveAdapters();
    box = await Hive.openBox<Medication>('medicationBox_test');
    repository = HiveMedicationRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  Medication sample({String id = '1'}) => Medication(
    id: id,
    name: 'Metformin',
    dosage: '500 mg',
    alarmHours: <int>[8, 20],
    alarmMinutes: <int>[0, 0],
  );

  test('add persists a medication', () async {
    await repository.add(sample());
    expect(repository.getAll(), hasLength(1));
    expect(repository.getById('1')?.name, 'Metformin');
  });

  test('add rejects a mismatched schedule', () {
    final Medication bad = Medication(
      id: '1',
      name: 'Metformin',
      dosage: '500 mg',
      alarmHours: <int>[8, 20],
      alarmMinutes: <int>[0],
    );
    expect(() => repository.add(bad), throwsA(isA<ValidationFailure>()));
  });

  test('add rejects an out-of-range time', () {
    final Medication bad = Medication(
      id: '1',
      name: 'Metformin',
      dosage: '500 mg',
      alarmHours: <int>[25],
      alarmMinutes: <int>[0],
    );
    expect(() => repository.add(bad), throwsA(isA<ValidationFailure>()));
  });

  test('delete removes a medication', () async {
    await repository.add(sample());
    await repository.delete('1');
    expect(repository.getAll(), isEmpty);
  });
}