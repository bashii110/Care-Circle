import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/core/services/service_providers.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/repository_providers.dart';
import 'package:care_circle/features/medications/application/medication_notifier.dart';
import 'package:care_circle/features/medications/domain/medication_schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../logic/fake_notification_service.dart';
import 'in_memory_medication_repository.dart';

void main() {
  Medication buildMedication({String id = 'med-1'}) => Medication(
        id: id,
        name: 'Metformin',
        dosage: '500 mg',
        alarmHours: <int>[8, 20],
        alarmMinutes: <int>[0, 0],
      );

  ProviderContainer buildContainer(InMemoryMedicationRepository repository) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        medicationRepositoryProvider.overrideWithValue(repository),
      ],
    );
    return container;
  }

  test('build() loads existing medications', () async {
    final ProviderContainer container = buildContainer(
      InMemoryMedicationRepository(seed: <Medication>[buildMedication()]),
    );
    addTearDown(container.dispose);

    final List<Medication> medications = await container.read(medicationNotifierProvider.future);
    expect(medications, hasLength(1));
  });

  test('addMedication adds up to the free-tier limit, then throws', () async {
    final ProviderContainer container = buildContainer(InMemoryMedicationRepository());
    addTearDown(container.dispose);
    await container.read(medicationNotifierProvider.future);

    final notifier = container.read(medicationNotifierProvider.notifier);
    await notifier.addMedication(buildMedication(id: 'med-1'));
    await notifier.addMedication(buildMedication(id: 'med-2'));
    await notifier.addMedication(buildMedication(id: 'med-3'));

    expect(container.read(medicationNotifierProvider).value, hasLength(3));

    await expectLater(
      () => notifier.addMedication(buildMedication(id: 'med-4')),
      throwsA(isA<ValidationFailure>()),
    );
    expect(container.read(medicationNotifierProvider).value, hasLength(3));
  });

  test('updateMedication persists changes', () async {
    final ProviderContainer container = buildContainer(
      InMemoryMedicationRepository(seed: <Medication>[buildMedication()]),
    );
    addTearDown(container.dispose);
    await container.read(medicationNotifierProvider.future);

    await container
        .read(medicationNotifierProvider.notifier)
        .updateMedication(buildMedication().copyWith(dosage: '1000 mg'));

    final List<Medication> medications = container.read(medicationNotifierProvider).value!;
    expect(medications.single.dosage, '1000 mg');
  });

  test('deleteMedication removes it', () async {
    final ProviderContainer container = buildContainer(
      InMemoryMedicationRepository(seed: <Medication>[buildMedication()]),
    );
    addTearDown(container.dispose);
    await container.read(medicationNotifierProvider.future);

    await container.read(medicationNotifierProvider.notifier).deleteMedication('med-1');

    expect(container.read(medicationNotifierProvider).value, isEmpty);
  });

  group('markTaken / markSkipped', () {
    test('markTaken records a true compliance entry at the exact scheduled key', () async {
      final ProviderContainer container = buildContainer(
        InMemoryMedicationRepository(seed: <Medication>[buildMedication()]),
      );
      addTearDown(container.dispose);
      await container.read(medicationNotifierProvider.future);

      final DateTime scheduledAt = DateTime(2026, 8, 30, 8, 0);
      await container
          .read(medicationNotifierProvider.notifier)
          .markTaken('med-1', scheduledAt);

      final Medication updated = container.read(medicationNotifierProvider).value!.single;
      expect(
        updated.complianceHistory[MedicationSchedule.complianceKeyFor(scheduledAt)],
        isTrue,
      );
    });

    test('markSkipped records a false compliance entry', () async {
      final ProviderContainer container = buildContainer(
        InMemoryMedicationRepository(seed: <Medication>[buildMedication()]),
      );
      addTearDown(container.dispose);
      await container.read(medicationNotifierProvider.future);

      final DateTime scheduledAt = DateTime(2026, 8, 30, 20, 0);
      await container
          .read(medicationNotifierProvider.notifier)
          .markSkipped('med-1', scheduledAt);

      final Medication updated = container.read(medicationNotifierProvider).value!.single;
      expect(
        updated.complianceHistory[MedicationSchedule.complianceKeyFor(scheduledAt)],
        isFalse,
      );
    });

    test('marking compliance for a missing medication throws StorageFailure', () async {
      final ProviderContainer container = buildContainer(InMemoryMedicationRepository());
      addTearDown(container.dispose);
      await container.read(medicationNotifierProvider.future);

      await expectLater(
        () => container
            .read(medicationNotifierProvider.notifier)
            .markTaken('does-not-exist', DateTime(2026, 8, 30, 8, 0)),
        throwsA(isA<StorageFailure>()),
      );
    });
  });

  group('notification reconciliation (Phase 4)', () {
    ProviderContainer buildContainerWithNotifications(
      InMemoryMedicationRepository repository,
      FakeNotificationService fake,
    ) {
      return ProviderContainer(
        overrides: <Override>[
          medicationRepositoryProvider.overrideWithValue(repository),
          notificationServiceProvider.overrideWithValue(fake),
        ],
      );
    }

    test('build() schedules reminders for every already-persisted medication', () async {
      final FakeNotificationService fake = FakeNotificationService();
      final ProviderContainer container = buildContainerWithNotifications(
        InMemoryMedicationRepository(seed: <Medication>[buildMedication()]),
        fake,
      );
      addTearDown(container.dispose);

      await container.read(medicationNotifierProvider.future);

      expect(fake.scheduled, hasLength(2)); // 8:00 and 20:00
    });

    test('addMedication schedules reminders for the new medication', () async {
      final FakeNotificationService fake = FakeNotificationService();
      final ProviderContainer container =
          buildContainerWithNotifications(InMemoryMedicationRepository(), fake);
      addTearDown(container.dispose);
      await container.read(medicationNotifierProvider.future);

      await container.read(medicationNotifierProvider.notifier).addMedication(buildMedication());

      expect(fake.scheduled, hasLength(2));
    });

    test('deleteMedication cancels its reminders', () async {
      final FakeNotificationService fake = FakeNotificationService();
      final ProviderContainer container = buildContainerWithNotifications(
        InMemoryMedicationRepository(seed: <Medication>[buildMedication()]),
        fake,
      );
      addTearDown(container.dispose);
      await container.read(medicationNotifierProvider.future);
      expect(fake.scheduled, hasLength(2));

      await container.read(medicationNotifierProvider.notifier).deleteMedication('med-1');

      expect(fake.scheduled, isEmpty);
      expect(fake.cancelled, hasLength(2));
    });

    test(
      'a notification failure does not prevent the medication mutation from succeeding',
      () async {
        // No notificationServiceProvider override at all — every
        // reconciliation attempt throws UnimplementedError internally,
        // and addMedication must still succeed.
        final ProviderContainer container =
            buildContainer(InMemoryMedicationRepository());
        addTearDown(container.dispose);
        await container.read(medicationNotifierProvider.future);

        await container
            .read(medicationNotifierProvider.notifier)
            .addMedication(buildMedication());

        expect(container.read(medicationNotifierProvider).value, hasLength(1));
      },
    );
  });
}
