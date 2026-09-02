import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/service_providers.dart';

/// The dashboard's emergency-call action (design.md §6 / §18 —
/// "EmergencyCallButton"; srd.md FR-09).
///
/// Disabled if [phoneNumber] is empty (FR-09 — "Validate that an
/// emergency contact exists"), though in practice `SeniorProfile.
/// emergencyContactPhone` is a required, validated field, so this is a
/// defensive fallback rather than an expected state.
class EmergencyCallButton extends ConsumerWidget {
  const EmergencyCallButton({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool hasNumber = phoneNumber.trim().isNotEmpty;

    return FilledButton.icon(
      onPressed: hasNumber ? () => _placeCall(context, ref) : null,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        minimumSize: const Size(kMinTouchTarget, kMinTouchTarget),
      ),
      icon: const Icon(Icons.call),
      label: const Text('CALL'),
    );
  }

  Future<void> _placeCall(BuildContext context, WidgetRef ref) async {
    final bool opened = await ref.read(emergencyCallServiceProvider).callNumber(phoneNumber);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("We couldn't open the phone app.")),
      );
    }
  }
}
