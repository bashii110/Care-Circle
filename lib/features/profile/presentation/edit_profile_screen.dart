import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/care_models.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../application/profile_notifier.dart';
import 'senior_profile_form.dart';

/// Lets a caregiver edit an existing [SeniorProfile] (srd.md §6 —
/// "Secondary screens: ... Senior profile").
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key, required this.profile});

  final SeniorProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CareScaffold(
      title: 'Edit Profile',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SeniorProfileForm(
          initialProfile: profile,
          submitLabel: 'Save Changes',
          onSubmit: (SeniorProfile updated) async {
            try {
              await ref.read(profileNotifierProvider.notifier).updateProfile(updated);
              if (context.mounted) Navigator.of(context).pop();
              return null;
            } on Failure catch (failure) {
              return failure.message;
            }
          },
        ),
      ),
    );
  }
}
