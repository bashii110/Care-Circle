import 'package:flutter/material.dart';

import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/phase_placeholder.dart';

/// Dashboard tab.
///
/// This is intentionally a placeholder: the real dashboard (senior header,
/// emergency call, progress ring, timeline, medication cards) is built in
/// Phase 5, once the data layer (Phase 1) and medication management
/// (Phase 3) it depends on exist. Per the master prompt's "Important Rule"
/// (§23), this screen does not fake that functionality — it only
/// establishes the navigation destination.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CareScaffold(
      title: 'Dashboard',
      body: PhasePlaceholder(
        icon: Icons.dashboard_outlined,
        message: "Today's care timeline will appear here.",
        phaseNote: 'Built in Phase 5, after the data layer is in place.',
      ),
    );
  }
}
