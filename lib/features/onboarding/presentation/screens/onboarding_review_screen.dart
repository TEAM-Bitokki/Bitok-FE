import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_profile_card.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_diet_label.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// 온보딩 3단계: 입력한 프로필을 확인하고 서버에 저장하는 화면입니다.
///
/// 저장하는 동안 버튼이 비활성화되고, 실패하면 다시 시도하라고 안내합니다.
class OnboardingReviewScreen extends ConsumerStatefulWidget {
  const OnboardingReviewScreen({super.key});

  @override
  ConsumerState<OnboardingReviewScreen> createState() =>
      _OnboardingReviewScreenState();
}

class _OnboardingReviewScreenState extends ConsumerState<OnboardingReviewScreen>
    with SavingStateMixin {
  Future<void> _onNext() => runSaving(() async {
    await ref.read(onboardingProvider.notifier).submit();
    if (mounted) context.go(AppRoutes.onboardingComplete);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider);

    return OnboardingStepScaffold(
      headerTitle: l10n.onboardingReviewHeader,
      step: 3,
      title: l10n.onboardingReviewTitle,
      onNext: saving ? null : _onNext,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            BitokProfileCard(
              title: l10n.onboardingReviewAllergiesTitle,
              description: state.allergies.isEmpty
                  ? l10n.onboardingReviewNone
                  : state.allergies.map((a) => a.label).join(' · '),
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
