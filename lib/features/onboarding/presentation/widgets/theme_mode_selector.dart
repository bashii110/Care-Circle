import 'package:flutter/material.dart';

/// A compact System / Light / Dark picker.
///
/// This satisfies srd.md FR-01's "Allow the caregiver to select
/// light/dark/high-contrast preferences" for the light/dark half. A
/// high-contrast *toggle* is deliberately not offered here yet: today it
/// would have no real effect beyond the standard theme, since actual
/// high-contrast color validation is Phase 9's job (Accessibility & UX
/// Hardening) — adding the control now would be exactly the kind of
/// looks-done-but-isn't feature the master prompt's "Important Rule"
/// (§23) warns against.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Appearance', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto_outlined),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: <ThemeMode>{selected},
          onSelectionChanged: (Set<ThemeMode> selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}
