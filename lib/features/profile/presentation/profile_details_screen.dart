import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/care_models.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../application/profile_notifier.dart';
import 'edit_profile_screen.dart';

/// Shows the active senior's profile (srd.md §6 — "Profile details").
///
/// This is what proves Phase 2's exit criteria end-to-end: after creating
/// a profile in onboarding and restarting the app, this screen shows the
/// same data, read back from [profileNotifierProvider] (which in turn
/// reads from the Hive-backed repository built in Phase 1).
class ProfileDetailsScreen extends ConsumerWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<SeniorProfile>> profilesState = ref.watch(profileNotifierProvider);

    return CareScaffold(
      title: 'Senior Profile',
      body: profilesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => const ErrorStateCard(),
        data: (List<SeniorProfile> profiles) {
          if (profiles.isEmpty) {
            return const EmptyStateCard(
              icon: Icons.person_outline,
              title: 'No profile yet',
              message: "Add the person you're caring for to start tracking their care.",
            );
          }
          return _ProfileView(profile: profiles.first);
        },
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.profile});

  final SeniorProfile profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(profile.fullName, style: textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Age ${profile.age}', style: textTheme.bodyLarge),
        const SizedBox(height: 24),
        _ProfileField(label: 'Primary condition', value: profile.primaryCondition),
        _ProfileField(label: 'Emergency contact', value: profile.emergencyContactPhone),
        _ProfileField(label: 'Blood type', value: profile.bloodType),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => EditProfileScreen(profile: profile),
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Profile'),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(value?.isNotEmpty == true ? value! : 'Not provided', style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
