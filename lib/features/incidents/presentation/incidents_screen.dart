import 'package:flutter/material.dart';

import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/phase_placeholder.dart';

/// Incidents tab. Real implementation (severity, behavior tags,
/// date-grouped feed) arrives in Phase 7.
class IncidentsScreen extends StatelessWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CareScaffold(
      title: 'Incidents',
      body: PhasePlaceholder(
        icon: Icons.event_note_outlined,
        message: 'Behavioral notes and events will appear here.',
        phaseNote: 'Built in Phase 7.',
      ),
    );
  }
}
