import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/care_models.dart';
import '../../../logic/care_timeline_engine.dart';
import '../../../shared/widgets/care_scaffold.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../medications/application/medication_notifier.dart';
import '../../medications/domain/medication_schedule.dart';
import '../../medications/presentation/medication_list_screen.dart';
import '../../profile/application/profile_notifier.dart';
import '../application/dashboard_providers.dart';
import 'widgets/dashboard_timeline_tile.dart';
import 'widgets/senior_profile_header.dart';

/// Dashboard tab (phases.md Phase 5) — the primary daily-care experience.
///
/// Per design.md §6, this is built from: a senior header with emergency
/// call, a progress ring, today's medication timeline, and quick actions.
/// The progress ring and timeline are both derived live from
/// [medicationNotifierProvider] via [CareTimelineEngine] — nothing here is
/// separately stored, so the dashboard can never drift out of sync with
/// the medication data it's summarizing (architecture.md §7).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SeniorProfile? profile = ref.watch(activeSeniorProfileProvider);
    final AsyncValue<List<Medication>> medicationsState = ref.watch(medicationNotifierProvider);

    return CareScaffold(
      title: 'Dashboard',
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.medication_outlined),
          tooltip: 'Manage medications',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MedicationListScreen()),
            );
          },
        ),
      ],
      body: medicationsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => const ErrorStateCard(),
        data: (List<Medication> medications) {
          final List<TimelineItem> timeline = ref.watch(dashboardTimelineProvider);
          final int completed =
              timeline.where((TimelineItem i) => i.status == MedicationEventStatus.completed).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              if (profile != null) SeniorProfileHeader(profile: profile),
              const SizedBox(height: 16),
              Center(child: ProgressRing(completed: completed, total: timeline.length)),
              const SizedBox(height: 24),
              Text('TODAY', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (timeline.isEmpty)
                EmptyStateCard(
                  icon: Icons.medication_outlined,
                  title: 'No medications yet',
                  message: 'Add a medication schedule to start\ntracking daily care.',
                  actionLabel: 'Add Medication',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const MedicationListScreen()),
                    );
                  },
                )
              else
                for (final TimelineItem item in timeline) ...<Widget>[
                  DashboardTimelineTile(item: item),
                  const SizedBox(height: 8),
                ],
              const SizedBox(height: 24),
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Row(
                children: <Widget>[
                  Expanded(
                    child: _QuickActionButton(icon: Icons.monitor_heart_outlined, label: 'Log Vital'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionButton(icon: Icons.event_note_outlined, label: 'Incident'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A quick-action button (design.md §6 — "[+ Log Vital] [+ Incident]").
///
/// Disabled for now: Vitals (Phase 6) and Incidents (Phase 7) don't exist
/// yet. Per the master prompt's "Important Rule" (§23), this shows the
/// real, designed control rather than a fake destination — it's visibly
/// inert with a "Coming soon" tooltip instead of silently navigating
/// nowhere or opening a screen that only pretends to log something.
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Coming soon',
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(kMinTouchTarget)),
      ),
    );
  }
}
