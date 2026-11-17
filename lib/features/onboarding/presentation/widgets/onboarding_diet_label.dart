import '../../../../l10n/generated/app_localizations.dart';
import '../providers/onboarding_state.dart';

/// 식단 선택지의 화면 표시 문구입니다.
String dietLabel(AppLocalizations l10n, DietType diet) {
  return switch (diet) {
    DietType.noParticularDiet => l10n.dietNoParticular,
    DietType.vegan => l10n.dietVegan,
    DietType.vegetarian => l10n.dietVegetarian,
    DietType.pescatarian => l10n.dietPescatarian,
  };
}

/// 프로필 확인 카드에 표시할 식단 요약입니다.
/// 예: 'Vegetarian · Eggs · Dairy'
String dietSummary(AppLocalizations l10n, OnboardingState state) {
  return dietSummaryOf(
    l10n,
    diet: state.diet ?? DietType.noParticularDiet,
    eatsEggs: state.eatsEggs,
    eatsDairy: state.eatsDairy,
  );
}

/// [dietSummary]와 같은 요약을 값으로 만듭니다. (마이페이지 Dietary Profile 등)
String dietSummaryOf(
  AppLocalizations l10n, {
  required DietType diet,
  required bool eatsEggs,
  required bool eatsDairy,
}) {
  return [
    dietLabel(l10n, diet),
    if (diet == DietType.vegetarian && eatsEggs) l10n.dietEggs,
    if (diet == DietType.vegetarian && eatsDairy) l10n.dietDairy,
  ].join(' · ');
}
