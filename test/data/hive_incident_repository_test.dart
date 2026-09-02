import 'dart:io';

import 'package:care_circle/core/constants/app_constants.dart';
import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/hive_incident_repository.dart';
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

  IncidentLog buildIncident({
    String id = 'incident-1',
    DateTime? timestamp,
    IncidentSeverity severity = IncidentSeverity.medium,
  }) =>
      IncidentLog(
        id: id,
        timestamp: timestamp ?? DateTime.now(),
        severity: severity.storageValue,
        behaviorTags: 'Confusion',
      );

  test('an empty database returns an empty list', () async {
    final Box<IncidentLog> box = await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);
    final HiveIncidentRepository repository = HiveIncidentRepository(box);

    expect(await repository.getAll(), isEmpty);
  });

  test('add/getAll/getById/update/delete form a working CRUD cycle', () async {
    final Box<IncidentLog> box = await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);
    final HiveIncidentRepository repository = HiveIncidentRepository(box);

    await repository.add(buildIncident());
    expect(await repository.getAll(), hasLength(1));

    await repository.update(
      buildIncident().copyWith(detailedDescription: 'Settled after 10 minutes.'),
    );
    expect(
      (await repository.getById('incident-1'))?.detailedDescription,
      'Settled after 10 minutes.',
    );

    await repository.delete('incident-1');
    expect(await repository.getAll(), isEmpty);
  });

  test('getAll returns incidents most-recent-first', () async {
    final Box<IncidentLog> box = await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);
    final HiveIncidentRepository repository = HiveIncidentRepository(box);

    final DateTime now = DateTime.now();
    await repository.add(
      buildIncident(id: 'old', timestamp: now.subtract(const Duration(days: 2))),
    );
    await repository.add(buildIncident(id: 'new', timestamp: now));

    final List<IncidentLog> all = await repository.getAll();
    expect(all.map((IncidentLog i) => i.id), <String>['new', 'old']);
  });

  test('add rejects an incident with neither tags nor description', () async {
    final Box<IncidentLog> box = await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);
    final HiveIncidentRepository repository = HiveIncidentRepository(box);

    final IncidentLog invalid = IncidentLog(
      id: 'incident-1',
      timestamp: DateTime.now(),
      severity: IncidentSeverity.low.storageValue,
    );

    await expectLater(
      () => repository.add(invalid),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('records survive an app restart', () async {
    final Box<IncidentLog> firstOpen =
        await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);
    await HiveIncidentRepository(firstOpen).add(buildIncident());

    await Hive.close();

    final Box<IncidentLog> secondOpen =
        await Hive.openBox<IncidentLog>(HiveBoxNames.incidents);
    expect(secondOpen.get('incident-1'), isNotNull);
  });
}
