import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Shared layout for a concise, single-purpose onboarding step
/// (design.md §12): an icon, a title, a subtitle, optional extra content,
/// and one large primary call-to-action pinned near the bottom.
///
/// Using one shared layout for steps 1 and 2 keeps them visually
/// consistent and keeps `OnboardingFlow` from repeating the same
/// padding/typography choices twice.
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onPressed,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onPressed;

  /// Optional additional content shown between the subtitle and the CTA
  /// (used by the privacy step for the theme-mode selector).
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: <Widget>[
            const Spacer(),
            Icon(icon, size: 64, color: colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              title,
              style: textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (extra != null) ...<Widget>[
              const SizedBox(height: 32),
              extra!,
            ],
            const Spacer(),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinTouchTarget),
              ),
              child: Text(ctaLabel),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
