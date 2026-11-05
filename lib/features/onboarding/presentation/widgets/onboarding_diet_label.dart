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
  final diet = state.diet ?? DietType.noParticularDiet;
  return [
    dietLabel(l10n, diet),
    if (diet == DietType.vegetarian && state.eatsEggs) l10n.dietEggs,
    if (diet == DietType.vegetarian && state.eatsDairy) l10n.dietDairy,
  ].join(' · ');
}
