import 'package:flutter/material.dart';

import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/phase_placeholder.dart';

/// Handover tab. Real implementation (time range, section toggles,
/// report generation, native sharing) arrives in Phase 8.
class HandoverScreen extends StatelessWidget {
  const HandoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CareScaffold(
      title: 'Handover',
      body: PhasePlaceholder(
        icon: Icons.summarize_outlined,
        message: 'Generate a shareable caregiver handover report.',
        phaseNote: 'Built in Phase 8.',
      ),
    );
  }
}
