import 'package:flutter/material.dart';

/// A clean, explicit "not built yet" boundary for a feature screen.
///
/// Per the master prompt §23 ("Do not generate placeholder implementations
/// for important functionality"), this widget is deliberately honest about
/// what it is — it never simulates real data or fake success states. It
/// exists so Phase 0 can wire up navigation to all four primary
/// destinations (design.md §5) without pretending later phases are done.
class PhasePlaceholder extends StatelessWidget {
  const PhasePlaceholder({
    super.key,
    required this.icon,
    required this.message,
    required this.phaseNote,
  });

  final IconData icon;
  final String message;
  final String phaseNote;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              phaseNote,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
