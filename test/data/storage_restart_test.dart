import 'dart:io';

import 'package:care_circle/data/repositories/profile_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:care_circle/data/adapters/hive_adapters.dart';
import 'package:care_circle/data/models/care_models.dart';

void main() {
  test('profile records survive a simulated app restart', () async {
    final Directory tempDir =
    await Directory.systemTemp.createTemp('care_circle_restart_test_');
    try {
      Hive.init(tempDir.path);
      registerHiveAdapters();

      // "First launch": write a record, then close everything, exactly
      // as happens when the app process ends.
      Box<SeniorProfile> box = await Hive.openBox<SeniorProfile>('profileBox');
      await HiveProfileRepository(box).add(SeniorProfile(
        id: '1',
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '555-0100',
      ));
      await Hive.close();

      // "Restart": re-init against the same directory, as
      // HiveStorageService.init() does in main.dart.
      Hive.init(tempDir.path);
      registerHiveAdapters();
      box = await Hive.openBox<SeniorProfile>('profileBox');
      final HiveProfileRepository repository = HiveProfileRepository(box);

      expect(repository.getAll(), hasLength(1));
      expect(repository.getById('1')?.fullName, 'Ahmed');
    } finally {
      await Hive.close();
      await tempDir.delete(recursive: true);
    }
  });

  test('empty database works with no prior records', () async {
    final Directory tempDir =
    await Directory.systemTemp.createTemp('care_circle_empty_test_');
    try {
      Hive.init(tempDir.path);
      registerHiveAdapters();
      final Box<SeniorProfile> box =
      await Hive.openBox<SeniorProfile>('profileBox');
      expect(HiveProfileRepository(box).getAll(), isEmpty);
    } finally {
      await Hive.close();
      await tempDir.delete(recursive: true);
    }
  });
}