import 'dart:io';

import 'package:care_circle/core/constants/app_constants.dart';
import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/hive_vitals_repository.dart';
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

  HealthVital buildVital({
    String id = 'vital-1',
    DateTime? timestamp,
    VitalType type = VitalType.weight,
    double primaryValue = 70,
  }) =>
      HealthVital(
        id: id,
        timestamp: timestamp ?? DateTime.now(),
        vitalType: type.storageValue,
        primaryValue: primaryValue,
      );

  test('an empty database returns an empty list', () async {
    final Box<HealthVital> box = await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
    final HiveVitalsRepository repository = HiveVitalsRepository(box);

    expect(await repository.getAll(), isEmpty);
  });

  test('add/getAll/getById/update/delete form a working CRUD cycle', () async {
    final Box<HealthVital> box = await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
    final HiveVitalsRepository repository = HiveVitalsRepository(box);

    await repository.add(buildVital());
    expect(await repository.getAll(), hasLength(1));

    await repository.update(buildVital().copyWith(primaryValue: 71));
    expect((await repository.getById('vital-1'))?.primaryValue, 71);

    await repository.delete('vital-1');
    expect(await repository.getAll(), isEmpty);
  });

  test('getByTypeInRange filters by type and time range, sorted ascending', () async {
    final Box<HealthVital> box = await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
    final HiveVitalsRepository repository = HiveVitalsRepository(box);

    final DateTime now = DateTime.now();
    await repository.add(
      buildVital(
        id: 'v1',
        type: VitalType.weight,
        timestamp: now.subtract(const Duration(days: 10)),
      ),
    ); // outside range
    await repository.add(
      buildVital(id: 'v2', type: VitalType.weight, timestamp: now.subtract(const Duration(days: 2))),
    );
    await repository.add(
      buildVital(id: 'v3', type: VitalType.weight, timestamp: now.subtract(const Duration(days: 1))),
    );
    await repository.add(
      buildVital(
        id: 'v4',
        type: VitalType.bloodPressure,
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ); // wrong type

    final List<HealthVital> result = await repository.getByTypeInRange(
      VitalType.weight,
      from: now.subtract(const Duration(days: 7)),
      to: now,
    );

    expect(result.map((HealthVital v) => v.id), <String>['v2', 'v3']);
  });

  test('add rejects a non-positive measurement', () async {
    final Box<HealthVital> box = await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
    final HiveVitalsRepository repository = HiveVitalsRepository(box);

    await expectLater(
      () => repository.add(buildVital(primaryValue: 0)),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('records survive an app restart', () async {
    final Box<HealthVital> firstOpen = await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
    await HiveVitalsRepository(firstOpen).add(buildVital());

    await Hive.close();

    final Box<HealthVital> secondOpen = await Hive.openBox<HealthVital>(HiveBoxNames.vitals);
    expect(secondOpen.get('vital-1'), isNotNull);
  });
}
