import 'package:flutter/material.dart';

import '../../../../data/models/care_models.dart';
import '../../../../shared/widgets/emergency_call_button.dart';
import '../../../profile/presentation/profile_details_screen.dart';

/// The dashboard's senior-profile header (design.md §6 / §18 —
/// "SeniorProfileHeader"): name, age, and the emergency call action.
///
/// The whole row (aside from the CALL button itself) is tappable through
/// to the full [ProfileDetailsScreen] — a natural way to reach "view/edit
/// profile" without a dedicated app-bar icon competing for space.
class SeniorProfileHeader extends StatelessWidget {
  const SeniorProfileHeader({super.key, required this.profile});

  final SeniorProfile profile;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ProfileDetailsScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.person, size: 28, color: Theme.of(context).colorScheme.onPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(profile.fullName, style: textTheme.headlineMedium),
                    Text('Age ${profile.age}', style: textTheme.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              EmergencyCallButton(phoneNumber: profile.emergencyContactPhone),
            ],
          ),
        ),
      ),
    );
  }
}
