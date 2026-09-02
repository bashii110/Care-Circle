import 'package:care_circle/core/errors/failures.dart';
import 'package:care_circle/data/models/care_models.dart';
import 'package:care_circle/data/repositories/repository_providers.dart';
import 'package:care_circle/features/profile/application/profile_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'in_memory_profile_repository.dart';

void main() {
  SeniorProfile buildProfile({String id = 'senior-1'}) => SeniorProfile(
        id: id,
        fullName: 'Ahmed',
        age: 72,
        emergencyContactPhone: '+92 300 1234567',
      );

  test('build() starts empty when the repository has no profiles', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
      ],
    );
    addTearDown(container.dispose);

    final List<SeniorProfile> profiles = await container.read(profileNotifierProvider.future);
    expect(profiles, isEmpty);
    expect(container.read(activeSeniorProfileProvider), isNull);
  });

  test('build() loads existing profiles from the repository', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(
          InMemoryProfileRepository(seed: <SeniorProfile>[buildProfile()]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final List<SeniorProfile> profiles = await container.read(profileNotifierProvider.future);
    expect(profiles, hasLength(1));
    expect(container.read(activeSeniorProfileProvider)?.fullName, 'Ahmed');
  });

  test('createProfile adds a profile and updates state', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(profileNotifierProvider.future); // let build() settle
    await container.read(profileNotifierProvider.notifier).createProfile(buildProfile());

    final List<SeniorProfile> profiles = container.read(profileNotifierProvider).value!;
    expect(profiles, hasLength(1));
    expect(container.read(activeSeniorProfileProvider)?.fullName, 'Ahmed');
  });

  test('createProfile propagates ValidationFailure without mutating state', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(profileNotifierProvider.future);

    final SeniorProfile invalid = SeniorProfile(
      id: 'senior-1',
      fullName: '',
      age: 72,
      emergencyContactPhone: '+92 300 1234567',
    );

    await expectLater(
      () => container.read(profileNotifierProvider.notifier).createProfile(invalid),
      throwsA(isA<ValidationFailure>()),
    );
    expect(container.read(profileNotifierProvider).value, isEmpty);
  });

  test('updateProfile persists changes', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(
          InMemoryProfileRepository(seed: <SeniorProfile>[buildProfile()]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(profileNotifierProvider.future);
    await container
        .read(profileNotifierProvider.notifier)
        .updateProfile(buildProfile().copyWith(fullName: 'Ahmed Khan'));

    expect(container.read(activeSeniorProfileProvider)?.fullName, 'Ahmed Khan');
  });

  test('deleteProfile removes the profile', () async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(
          InMemoryProfileRepository(seed: <SeniorProfile>[buildProfile()]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(profileNotifierProvider.future);
    await container.read(profileNotifierProvider.notifier).deleteProfile('senior-1');

    expect(container.read(profileNotifierProvider).value, isEmpty);
    expect(container.read(activeSeniorProfileProvider), isNull);
  });
}
