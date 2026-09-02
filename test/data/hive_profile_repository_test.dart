import 'dart:io';

import 'package:care_circle/core/constants/app_constants.dart';
import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/hive_profile_repository.dart';
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

  SeniorProfile buildProfile({String id = 'senior-1'}) => SeniorProfile(
        id: id,
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '+92 300 1234567',
      );

  test('an empty database returns an empty list (Phase 1 exit criteria)', () async {
    final Box<SeniorProfile> box = await Hive.openBox<SeniorProfile>(HiveBoxNames.profiles);
    final HiveProfileRepository repository = HiveProfileRepository(box);

    expect(await repository.getAll(), isEmpty);
    expect(await repository.getById('missing'), isNull);
  });

  test('add/getAll/getById/update/delete form a working CRUD cycle', () async {
    final Box<SeniorProfile> box = await Hive.openBox<SeniorProfile>(HiveBoxNames.profiles);
    final HiveProfileRepository repository = HiveProfileRepository(box);

    await repository.add(buildProfile());
    expect(await repository.getAll(), hasLength(1));
    expect((await repository.getById('senior-1'))?.fullName, 'Ahmed');

    await repository.update(buildProfile().copyWith(fullName: 'Ahmed Khan'));
    expect((await repository.getById('senior-1'))?.fullName, 'Ahmed Khan');

    await repository.delete('senior-1');
    expect(await repository.getAll(), isEmpty);
  });

  test('add rejects an invalid profile with ValidationFailure', () async {
    final Box<SeniorProfile> box = await Hive.openBox<SeniorProfile>(HiveBoxNames.profiles);
    final HiveProfileRepository repository = HiveProfileRepository(box);

    final SeniorProfile invalid = SeniorProfile(
      id: 'senior-1',
      fullName: '',
      age: 72,
      emergencyContactPhone: '+92 300 1234567',
    );

    await expectLater(
      () => repository.add(invalid),
      throwsA(isA<ValidationFailure>()),
    );
    expect(await repository.getAll(), isEmpty);
  });

  test('update throws StorageFailure for a profile that does not exist', () async {
    final Box<SeniorProfile> box = await Hive.openBox<SeniorProfile>(HiveBoxNames.profiles);
    final HiveProfileRepository repository = HiveProfileRepository(box);

    await expectLater(
      () => repository.update(buildProfile(id: 'does-not-exist')),
      throwsA(isA<StorageFailure>()),
    );
  });

  test('records survive an app restart (Phase 1 exit criteria)', () async {
    final Box<SeniorProfile> firstOpen =
        await Hive.openBox<SeniorProfile>(HiveBoxNames.profiles);
    await HiveProfileRepository(firstOpen).add(buildProfile());

    // Simulate an app restart: close every box, then reopen against the
    // same on-disk directory (Hive.init in setUpTestHive already points at
    // tempDir, and closing does not delete data).
    await Hive.close();

    final Box<SeniorProfile> secondOpen =
        await Hive.openBox<SeniorProfile>(HiveBoxNames.profiles);
    final HiveProfileRepository repositoryAfterRestart = HiveProfileRepository(secondOpen);

    final List<SeniorProfile> restored = await repositoryAfterRestart.getAll();
    expect(restored, hasLength(1));
    expect(restored.single.fullName, 'Ahmed');
  });
}
