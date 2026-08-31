import 'package:flutter/material.dart';

import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/phase_placeholder.dart';

/// Vitals tab. Real implementation (quick-log actions, entry sheet,
/// 7/30-day charts) arrives in Phase 6.
class VitalsScreen extends StatelessWidget {
  const VitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CareScaffold(
      title: 'Vitals',
      body: PhasePlaceholder(
        icon: Icons.monitor_heart_outlined,
        message: 'Blood pressure, glucose, weight, and heart rate tracking.',
        phaseNote: 'Built in Phase 6.',
      ),
    );
  }
}
