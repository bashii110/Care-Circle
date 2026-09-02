import 'dart:io';

import 'package:care_circle/core/constants/app_constants.dart';
import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/hive_medication_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'hive_test_helper.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await setUpTestHive();
  });

  tearDown(() async {
    await tearDownTestHive(tempDir);
  });

  Medication buildMedication({String id = 'med-1'}) => Medication(
        id: id,
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[8, 20],
        alarmMinutes: <int>[0, 0],
      );

  test('an empty database returns an empty list', () async {
    final Box<Medication> box = await Hive.openBox<Medication>(HiveBoxNames.medications);
    final HiveMedicationRepository repository = HiveMedicationRepository(box);

    expect(await repository.getAll(), isEmpty);
  });

  test('add/getAll/getById/update/delete form a working CRUD cycle', () async {
    final Box<Medication> box = await Hive.openBox<Medication>(HiveBoxNames.medications);
    final HiveMedicationRepository repository = HiveMedicationRepository(box);

    await repository.add(buildMedication());
    expect(await repository.getAll(), hasLength(1));

    await repository.update(buildMedication().copyWith(dosage: '1000 mg'));
    expect((await repository.getById('med-1'))?.dosage, '1000 mg');

    await repository.delete('med-1');
    expect(await repository.getAll(), isEmpty);
  });

  test('add rejects a medication with no reminder times', () async {
    final Box<Medication> box = await Hive.openBox<Medication>(HiveBoxNames.medications);
    final HiveMedicationRepository repository = HiveMedicationRepository(box);

    final Medication invalid = Medication(
      id: 'med-1',
      name: 'Metformin',
      dosage: '500 mg',
      alarmHours: <int>[],
      alarmMinutes: <int>[],
    );

    await expectLater(
      () => repository.add(invalid),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('delete throws StorageFailure for a medication that does not exist', () async {
    final Box<Medication> box = await Hive.openBox<Medication>(HiveBoxNames.medications);
    final HiveMedicationRepository repository = HiveMedicationRepository(box);

    await expectLater(
      () => repository.delete('does-not-exist'),
      throwsA(isA<StorageFailure>()),
    );
  });

  test('compliance history survives an app restart', () async {
    final Box<Medication> firstOpen =
        await Hive.openBox<Medication>(HiveBoxNames.medications);
    await HiveMedicationRepository(firstOpen).add(
      buildMedication().copyWith(
        complianceHistory: const <String, bool>{'2026-08-30T08:00': true},
      ),
    );

    await Hive.close();

    final Box<Medication> secondOpen =
        await Hive.openBox<Medication>(HiveBoxNames.medications);
    final Medication? restored = secondOpen.get('med-1');

    expect(restored, isNotNull);
    expect(restored!.complianceHistory, <String, bool>{'2026-08-30T08:00': true});
  });
}
