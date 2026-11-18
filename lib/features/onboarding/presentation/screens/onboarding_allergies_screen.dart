import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_deletable_chip.dart';
import '../../../../common/widgets/bitok_search_field.dart';
import '../../../../common/widgets/bitok_selection_tile.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// 온보딩 2단계: 알레르기 선택 화면입니다.
///
/// 검색어로 알레르기 목록을 거르고, 여러 개를 고를 수 있습니다.
/// 고른 항목은 하단 버튼 위에 가로로 스크롤되는 칩으로 표시됩니다.
///
/// [onSave]를 넘기면 마이페이지의 수정 화면으로 쓰입니다.
/// 진행 단계와 Skip을 숨기고, 하단 버튼이 Save가 됩니다.
class OnboardingAllergiesScreen extends ConsumerStatefulWidget {
  const OnboardingAllergiesScreen({super.key, this.onSave});

  final VoidCallback? onSave;

  @override
  ConsumerState<OnboardingAllergiesScreen> createState() =>
      _OnboardingAllergiesScreenState();
}

class _OnboardingAllergiesScreenState
    extends ConsumerState<OnboardingAllergiesScreen> {
  String _query = '';

  List<String> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return onboardingAllergyCatalog;
    return onboardingAllergyCatalog
        .where((allergy) => allergy.toLowerCase().contains(query))
        .toList();
  }

  void _goToDiet() {
    FocusScope.of(context).unfocus();
    context.push(AppRoutes.onboardingDiet);
  }

  void _onSkip() {
    ref.read(onboardingProvider.notifier).clearAllergies();
    _goToDiet();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      onboardingProvider.select((state) => state.allergies),
    );
    final notifier = ref.read(onboardingProvider.notifier);
    final results = _results;
    final onSave = widget.onSave;
    final editing = onSave != null;

    return OnboardingStepScaffold(
      headerTitle: l10n.onboardingAllergiesHeader,
      step: editing ? null : 2,
      title: l10n.onboardingAllergiesTitle,
      onSkip: editing ? null : _onSkip,
      buttonLabel: editing ? l10n.commonSave : null,
      // 수정할 때는 알레르기를 모두 지우고 저장할 수도 있습니다.
      onNext: editing
          ? () {
              FocusScope.of(context).unfocus();
              onSave();
            }
          : (selected.isEmpty ? null : _goToDiet),
      bottomAccessory: selected.isEmpty
          ? null
          : _SelectedAllergyChips(
              allergies: selected,
              onDelete: notifier.toggleAllergy,
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BitokSearchField(
            hintText: l10n.onboardingAllergiesSearchHint,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 20),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final allergy = results[index];
                return BitokSelectionTile(
                  label: allergy,
                  selected: selected.contains(allergy),
                  onTap: () => notifier.toggleAllergy(allergy),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 선택한 알레르기를 보여주는 가로 스크롤 칩 목록입니다.
///
/// 항목이 많으면 오른쪽 화면 끝에서 잘리고, 옆으로 밀어 나머지를 볼 수 있습니다.
class _SelectedAllergyChips extends StatelessWidget {
  const _SelectedAllergyChips({
    required this.allergies,
    required this.onDelete,
  });

  final List<String> allergies;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BitokDeletableChip.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: OnboardingStepScaffold.horizontalPadding,
        ),
        itemCount: allergies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final allergy = allergies[index];
          return BitokDeletableChip(
            label: allergy,
            onDelete: () => onDelete(allergy),
          );
        },
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Onboarding · Allergies', size: Size(390, 844))
Widget onboardingAllergiesScreenPreview() => const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: OnboardingAllergiesScreen(),
  ),
);
