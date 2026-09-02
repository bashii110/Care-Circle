import 'package:flutter/material.dart';

/// The dashboard's daily-progress indicator (design.md §6 / §18 —
/// "ProgressRing"): a ring *plus* explicit "4 / 6" and label text.
///
/// design.md is explicit that completion must never be communicated by
/// the ring alone — the numeric fraction and [label] are always drawn on
/// top of it, not hidden behind a tooltip or content-description only.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.completed,
    required this.total,
    this.label = 'MEDS DONE',
    this.size = 140,
  });

  final int completed;
  final int total;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double fraction = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0).toDouble();
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 10,
              backgroundColor: colorScheme.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$completed / $total', style: textTheme.headlineMedium),
              Text(label, style: textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
