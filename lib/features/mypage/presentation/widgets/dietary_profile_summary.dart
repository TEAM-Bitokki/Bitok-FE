import '../../../../l10n/generated/app_localizations.dart';
import '../../../onboarding/presentation/widgets/onboarding_diet_label.dart';
import '../providers/dietary_profile_provider.dart';

/// Dietary Profile 화면의 알레르기 카드 요약입니다. 예: 'Shrimp · Anchovy · Walnut'
String allergySummaryOf(AppLocalizations l10n, DietaryProfile profile) {
  if (profile.allergies.isEmpty) return l10n.onboardingReviewNone;
  return profile.allergies.join(' · ');
}

/// Dietary Profile 화면의 식단 카드 요약입니다. 예: 'Vegetarian · Eggs'
String dietSummaryOfProfile(AppLocalizations l10n, DietaryProfile profile) {
  return dietSummaryOf(
    l10n,
    diet: profile.diet,
    eatsEggs: profile.eatsEggs,
    eatsDairy: profile.eatsDairy,
  );
}

/// 마이페이지 카드의 한 줄 요약입니다. 예: '3 food allergies · Vegetarian'
String myPageDietarySummaryOf(AppLocalizations l10n, DietaryProfile profile) {
  final allergies = l10n.myPageAllergyCount(profile.allergies.length);
  return '$allergies · ${dietLabel(l10n, profile.diet)}';
}
