import 'dart:io';

import 'package:care_circle/data/repositories/incident_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/adapters/hive_adapters.dart';
import 'package:care_circle/data/models/care_models.dart';


void main() {
  late Directory tempDir;
  late Box<IncidentLog> box;
  late HiveIncidentRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('care_circle_test_');
    Hive.init(tempDir.path);
    registerHiveAdapters();
    box = await Hive.openBox<IncidentLog>('incidentsBox_test');
    repository = HiveIncidentRepository(box);
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('add persists an incident', () async {
    await repository.add(IncidentLog(
      id: '1',
      timestamp: DateTime.now(),
      severity: IncidentSeverity.high,
      behaviorTags: 'Fall / Slip',
      detailedDescription: 'Senior appeared unsteady near the stairs.',
    ));
    expect(repository.getAll(), hasLength(1));
  });

  test('add rejects an invalid severity', () {
    final IncidentLog bad = IncidentLog(
      id: '1',
      timestamp: DateTime.now(),
      severity: 'urgent',
      behaviorTags: 'Confusion',
    );
    expect(() => repository.add(bad), throwsA(isA<ValidationFailure>()));
  });

  test('add rejects missing behavior tags', () {
    final IncidentLog bad = IncidentLog(
      id: '1',
      timestamp: DateTime.now(),
      severity: IncidentSeverity.low,
      behaviorTags: '',
    );
    expect(() => repository.add(bad), throwsA(isA<ValidationFailure>()));
  });
}