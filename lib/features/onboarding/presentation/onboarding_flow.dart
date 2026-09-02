import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../app/theme/theme_mode_codec.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/preferences_service.dart';
import '../../../data/models/care_models.dart';
import '../../profile/application/profile_notifier.dart';
import '../../profile/presentation/senior_profile_form.dart';
import 'widgets/onboarding_step_scaffold.dart';
import 'widgets/theme_mode_selector.dart';

/// The three concise onboarding steps from design.md §12.
///
/// Steps 1 and 2 are simple "read and continue" screens built on
/// [OnboardingStepScaffold]; step 3 embeds [SeniorProfileForm] directly,
/// since its own submit button *is* the step's call to action.
/// Completing step 3 flips [onboardingCompletedProvider], which is what
/// actually ends onboarding — see `app/app.dart`.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: kStandardTransitionDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Onboarding is a fixed, linear sequence — a caregiver can't skip
        // ahead by swiping past a step they haven't completed.
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          OnboardingStepScaffold(
            icon: Icons.favorite_outline,
            title: kAppName,
            subtitle: 'A simpler way to organize senior care.',
            ctaLabel: 'Get Started',
            onPressed: _goToNextStep,
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, _) {
              final ThemeMode currentThemeMode = ref.watch(themeModeProvider);
              return OnboardingStepScaffold(
                icon: Icons.lock_outline,
                title: 'Private by design',
                subtitle: 'Your care records stay on this device.',
                ctaLabel: 'Continue',
                onPressed: _goToNextStep,
                extra: ThemeModeSelector(
                  selected: currentThemeMode,
                  onChanged: (ThemeMode mode) {
                    ref.read(themeModeProvider.notifier).state = mode;
                    ref
                        .read(preferencesServiceProvider)
                        .setThemeMode(themeModeToStorageValue(mode));
                  },
                ),
              );
            },
          ),
          const _CreateProfileStep(),
        ],
      ),
    );
  }
}

class _CreateProfileStep extends ConsumerWidget {
  const _CreateProfileStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Add the person you're caring for.",
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: SeniorProfileForm(
                  submitLabel: 'Create Profile',
                  onSubmit: (SeniorProfile profile) => _createProfile(ref, profile),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _createProfile(WidgetRef ref, SeniorProfile profile) async {
    try {
      await ref.read(profileNotifierProvider.notifier).createProfile(profile);

      final PreferencesService preferences = ref.read(preferencesServiceProvider);
      await preferences.setOnboardingCompleted(true);
      await preferences.setSelectedProfileId(profile.id);

      // Reactive flip — this is what actually swaps CareCircleApp's `home`
      // from OnboardingFlow to CareCircleShell (see app/app.dart).
      ref.read(onboardingCompletedProvider.notifier).state = true;
      return null;
    } on Failure catch (failure) {
      return failure.message;
    }
  }
}
