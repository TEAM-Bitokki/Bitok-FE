import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_selection_tile.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../providers/onboarding_state.dart';
import '../widgets/onboarding_check_option.dart';
import '../widgets/onboarding_diet_label.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// 온보딩 2단계(이어서): 식단 선택 화면입니다.
///
/// 하나만 고를 수 있고, Vegetarian을 고르면 달걀·유제품 섭취 여부를 추가로 묻습니다.
class OnboardingDietScreen extends ConsumerWidget {
  const OnboardingDietScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return OnboardingStepScaffold(
      headerTitle: l10n.onboardingDietHeader,
      step: 2,
      title: l10n.onboardingDietTitle,
      onNext: state.diet == null
          ? null
          : () => context.push(AppRoutes.onboardingReview),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            for (final diet in DietType.values) ...[
              BitokSelectionTile(
                label: dietLabel(l10n, diet),
                selected: state.diet == diet,
                onTap: () => notifier.selectDiet(diet),
              ),
              if (diet == DietType.vegetarian &&
                  state.diet == DietType.vegetarian)
                Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      OnboardingCheckOption(
                        label: l10n.onboardingDietEatsEggs,
                        checked: state.eatsEggs,
                        onChanged: notifier.setEatsEggs,
                      ),
                      OnboardingCheckOption(
                        label: l10n.onboardingDietEatsDairy,
                        checked: state.eatsDairy,
                        onChanged: notifier.setEatsDairy,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Onboarding · Diet', size: Size(390, 844))
Widget onboardingDietScreenPreview() => const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: OnboardingDietScreen(),
  ),
);
