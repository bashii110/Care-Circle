import 'package:flutter/material.dart';

/// A [FormField] that manages a medication's list of daily reminder
/// times (srd.md FR-04 — "Define multiple daily reminder times").
///
/// Being a real [FormField] means its "at least one reminder time" rule
/// participates in the surrounding [Form]'s `validate()` call exactly
/// like the text fields around it, instead of needing a separate check
/// bolted on in the submit handler.
class ReminderTimesField extends FormField<List<TimeOfDay>> {
  ReminderTimesField({
    super.key,
    required List<TimeOfDay> initialTimes,
    required ValueChanged<List<TimeOfDay>> onChanged,
  }) : super(
          initialValue: List<TimeOfDay>.of(initialTimes),
          validator: (List<TimeOfDay>? value) {
            if (value == null || value.isEmpty) {
              return 'Add at least one reminder time.';
            }
            return null;
          },
          builder: (FormFieldState<List<TimeOfDay>> state) {
            final List<TimeOfDay> times = List<TimeOfDay>.of(state.value ?? const <TimeOfDay>[])
              ..sort(_compareTimeOfDay);

            Future<void> addTime() async {
              final TimeOfDay? picked = await showTimePicker(
                context: state.context,
                initialTime: TimeOfDay.now(),
              );
              if (picked == null) return;
              if (times.contains(picked)) return; // avoid duplicate reminders
              final List<TimeOfDay> updated = List<TimeOfDay>.of(times)
                ..add(picked)
                ..sort(_compareTimeOfDay);
              state.didChange(updated);
              onChanged(updated);
            }

            void removeTime(TimeOfDay time) {
              final List<TimeOfDay> updated = List<TimeOfDay>.of(times)..remove(time);
              state.didChange(updated);
              onChanged(updated);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Reminder times', style: Theme.of(state.context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final TimeOfDay time in times)
                      InputChip(
                        label: Text(time.format(state.context)),
                        onDeleted: () => removeTime(time),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('Add time'),
                      onPressed: addTime,
                    ),
                  ],
                ),
                if (state.hasError) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    state.errorText!,
                    style: TextStyle(color: Theme.of(state.context).colorScheme.error),
                  ),
                ],
              ],
            );
          },
        );

  static int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) =>
      (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
}
