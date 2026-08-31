import 'dart:io';

import 'package:care_circle/data/repositories/profile_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/adapters/hive_adapters.dart';
import 'package:care_circle/data/models/care_models.dart';


void main() {
  late Directory tempDir;
  late Box<SeniorProfile> box;
  late HiveProfileRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('care_circle_test_');
    Hive.init(tempDir.path);
    registerHiveAdapters();
    box = await Hive.openBox<SeniorProfile>('profileBox_test');
    repository = HiveProfileRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('starts empty', () {
    expect(repository.getAll(), isEmpty);
  });

  test('add persists a profile and getById finds it', () async {
    await repository.add(SeniorProfile(
      id: '1',
      fullName: 'Ahmed',
      age: 72,
      emergencyContactPhone: '555-0100',
    ));
    expect(repository.getAll(), hasLength(1));
    expect(repository.getById('1')?.fullName, 'Ahmed');
  });

  test('add rejects an empty full name', () {
    final SeniorProfile profile = SeniorProfile(
      id: '1',
      fullName: '  ',
      age: 72,
      emergencyContactPhone: '555-0100',
    );
    expect(() => repository.add(profile), throwsA(isA<ValidationFailure>()));
  });

  test('add rejects an invalid age', () {
    final SeniorProfile profile = SeniorProfile(
      id: '1',
      fullName: 'Ahmed',
      age: 0,
      emergencyContactPhone: '555-0100',
    );
    expect(() => repository.add(profile), throwsA(isA<ValidationFailure>()));
  });

  test('update overwrites an existing profile', () async {
    await repository.add(SeniorProfile(
      id: '1',
      fullName: 'Ahmed',
      age: 72,
      emergencyContactPhone: '555-0100',
    ));
    await repository.update(SeniorProfile(
      id: '1',
      fullName: 'Ahmed K.',
      age: 73,
      emergencyContactPhone: '555-0100',
    ));
    expect(repository.getById('1')?.fullName, 'Ahmed K.');
    expect(repository.getAll(), hasLength(1));
  });

  test('update rejects a profile that does not exist yet', () {
    final SeniorProfile profile = SeniorProfile(
      id: 'missing',
      fullName: 'Ahmed',
      age: 72,
      emergencyContactPhone: '555-0100',
    );
    expect(() => repository.update(profile), throwsA(isA<ValidationFailure>()));
  });

  test('delete removes a profile', () async {
    await repository.add(SeniorProfile(
      id: '1',
      fullName: 'Ahmed',
      age: 72,
      emergencyContactPhone: '555-0100',
    ));
    await repository.delete('1');
    expect(repository.getAll(), isEmpty);
  });
}