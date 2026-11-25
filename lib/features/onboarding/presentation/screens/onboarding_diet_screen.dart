import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_selection_tile.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
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
///
/// [onSave]를 넘기면 마이페이지의 수정 화면으로 쓰입니다.
/// 진행 단계를 숨기고, 하단 버튼이 Save가 됩니다.
/// 저장하는 동안 버튼이 비활성화되고, 실패하면 다시 시도하라고 안내합니다.
class OnboardingDietScreen extends ConsumerStatefulWidget {
  const OnboardingDietScreen({super.key, this.onSave});

  final Future<void> Function()? onSave;

  @override
  ConsumerState<OnboardingDietScreen> createState() =>
      _OnboardingDietScreenState();
}

class _OnboardingDietScreenState extends ConsumerState<OnboardingDietScreen>
    with SavingStateMixin {
  @override
  Widget build(BuildContext context) {
    final onSave = widget.onSave;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return OnboardingStepScaffold(
      headerTitle: l10n.onboardingDietHeader,
      step: onSave == null ? 2 : null,
      title: l10n.onboardingDietTitle,
      buttonLabel: onSave == null ? null : l10n.commonSave,
      onNext: state.diet == null || saving
          ? null
          : (onSave == null
                ? () => context.push(AppRoutes.onboardingReview)
                : () => runSaving(onSave)),
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
                // 저장하는 동안은 고칠 수 없게 합니다. 저장 시작 시점의 값만 저장되기 때문입니다.
                onTap: saving ? null : () => notifier.selectDiet(diet),
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
                        onChanged: (value) {
                          if (!saving) notifier.setEatsEggs(value);
                        },
                      ),
                      OnboardingCheckOption(
                        label: l10n.onboardingDietEatsDairy,
                        checked: state.eatsDairy,
                        onChanged: (value) {
                          if (!saving) notifier.setEatsDairy(value);
                        },
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
