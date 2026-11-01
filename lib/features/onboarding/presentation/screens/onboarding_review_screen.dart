import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_profile_card.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_diet_label.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// 온보딩 3단계: 입력한 프로필을 확인하고 저장하는 화면입니다.
class OnboardingReviewScreen extends ConsumerStatefulWidget {
  const OnboardingReviewScreen({super.key});

  @override
  ConsumerState<OnboardingReviewScreen> createState() =>
      _OnboardingReviewScreenState();
}

class _OnboardingReviewScreenState
    extends ConsumerState<OnboardingReviewScreen> {
  bool _submitting = false;

  Future<void> _onNext() async {
    setState(() => _submitting = true);
    try {
      await ref.read(onboardingProvider.notifier).submit();
      if (mounted) context.go(AppRoutes.onboardingComplete);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider);

    return OnboardingStepScaffold(
      headerTitle: l10n.onboardingReviewHeader,
      step: 3,
      title: l10n.onboardingReviewTitle,
      onNext: _submitting ? null : _onNext,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            BitokProfileCard(
              title: l10n.onboardingReviewAllergiesTitle,
              description: state.allergies.isEmpty
                  ? l10n.onboardingReviewNone
                  : state.allergies.join(' · '),
            ),
            BitokProfileCard(
              title: l10n.onboardingReviewDietTitle,
              description: dietSummary(l10n, state),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Onboarding · Review', size: Size(390, 844))
Widget onboardingReviewScreenPreview() => const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: OnboardingReviewScreen(),
  ),
);
