import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/care_models.dart';
import '../../../logic/care_timeline_engine.dart';
import '../../medications/application/medication_notifier.dart';

/// Today's medication timeline (architecture.md §6 —
/// `dashboardTimelineProvider`), derived from [medicationNotifierProvider].
///
/// A plain [Provider], not its own notifier: the timeline has no state of
/// its own to own or mutate — it's a pure recomputation of whatever
/// [medicationNotifierProvider] currently holds, matching architecture.md
/// §7's "The timeline should be derived rather than permanently stored."
final Provider<List<TimelineItem>> dashboardTimelineProvider = Provider<List<TimelineItem>>((ref) {
  final List<Medication> medications =
      ref.watch(medicationNotifierProvider).valueOrNull ?? const <Medication>[];
  return CareTimelineEngine.buildTodayTimeline(medications);
});
