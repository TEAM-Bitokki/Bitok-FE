import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_deletable_chip.dart';
import '../../../../common/widgets/bitok_search_field.dart';
import '../../../../common/widgets/bitok_selection_tile.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/models/allergen_item.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../mypage/data/models/ingredient_item.dart';
import '../providers/allergen_search_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// 온보딩 2단계: 알레르기 선택 화면입니다.
///
/// 검색어로 서버의 알레르기 목록(GET /api/ingredients/search)을 찾고, 여러 개를 고를 수 있습니다.
/// 검색어가 비어 있으면 전체 목록을 보여줍니다.
/// 고른 항목은 하단 버튼 위에 가로로 스크롤되는 칩으로 표시됩니다.
///
/// [onSave]를 넘기면 마이페이지의 수정 화면으로 쓰입니다.
/// 진행 단계와 Skip을 숨기고, 하단 버튼이 Save가 됩니다.
/// 저장하는 동안 버튼이 비활성화되고, 실패하면 다시 시도하라고 안내합니다.
class OnboardingAllergiesScreen extends ConsumerStatefulWidget {
  const OnboardingAllergiesScreen({super.key, this.onSave});

  final Future<void> Function()? onSave;

  @override
  ConsumerState<OnboardingAllergiesScreen> createState() =>
      _OnboardingAllergiesScreenState();
}

class _OnboardingAllergiesScreenState
    extends ConsumerState<OnboardingAllergiesScreen>
    with SavingStateMixin {
  /// 입력이 멈추고 이만큼 지나면 검색합니다. 글자마다 요청하지 않기 위해서입니다.
  static const _debounce = Duration(milliseconds: 300);

  String _query = '';
  Timer? _debounceTimer;

  /// 다음 검색어 결과를 받는 동안 보여줄 직전 결과입니다. 목록이 깜빡이지 않게 합니다.
  List<IngredientItem>? _lastResults;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      final query = value.trim();
      if (mounted && query != _query) setState(() => _query = query);
    });
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
    final search = ref.watch(allergenSearchProvider(_query));
    if (search case AsyncData(:final value)) _lastResults = value;
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
          ? (saving ? null : () => runSaving(onSave))
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
            onChanged: _onQueryChanged,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: switch ((search, _lastResults)) {
              (AsyncError(), _) => _SearchFailed(
                onRetry: () => ref.invalidate(allergenSearchProvider(_query)),
              ),
              (_, final results?) => ListView.separated(
                padding: const EdgeInsets.only(bottom: 20),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final allergy = results[index].toAllergen();
                  return BitokSelectionTile(
                    label: allergy.label,
                    selected: selected.contains(allergy),
                    onTap: () => notifier.toggleAllergy(allergy),
                  );
                },
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

/// 검색에 실패했을 때 안내 문구와 다시 시도 버튼입니다.
class _SearchFailed extends StatelessWidget {
  const _SearchFailed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorLoadFailed,
            style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
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

  final List<AllergenItem> allergies;
  final ValueChanged<AllergenItem> onDelete;

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
            label: allergy.label,
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
