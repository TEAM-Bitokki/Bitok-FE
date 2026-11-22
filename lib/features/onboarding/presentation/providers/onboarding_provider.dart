import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../mypage/presentation/providers/account_provider.dart';
import '../../../mypage/presentation/providers/dietary_profile_provider.dart';
import 'onboarding_state.dart';

// presentation/providers: 온보딩 단계별 입력을 모아두고, 마지막에 서버로 저장합니다.
// 각 단계 화면(presentation/screens)은 이 provider만 watch/read 합니다.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void toggleAllergy(AllergenItem allergy) {
    final allergies = state.allergies.contains(allergy)
        ? state.allergies.where((a) => a != allergy).toList()
        : [...state.allergies, allergy];
    state = state.copyWith(allergies: allergies);
  }

  void clearAllergies() {
    state = state.copyWith(allergies: const []);
  }

  void selectDiet(DietType diet) {
    state = state.copyWith(diet: diet);
  }

  void setEatsEggs(bool value) {
    state = state.copyWith(eatsEggs: value);
  }

  void setEatsDairy(bool value) {
    state = state.copyWith(eatsDairy: value);
  }

  /// 마이페이지에서 수정 화면을 열 때 현재 프로필을 입력값으로 불러옵니다.
  /// 수정 화면은 이 값을 고치다가 Save를 누를 때만 프로필에 반영합니다.
  void loadProfile(DietaryProfile profile) {
    state = state.copyWith(
      allergies: profile.allergies,
      diet: profile.diet,
      eatsEggs: profile.eatsEggs,
      eatsDairy: profile.eatsDairy,
    );
  }

  /// 입력한 프로필을 저장합니다.
  Future<void> submit() async {
    // TODO: 온보딩 저장 API가 준비되면 repository를 통해 state를 전송합니다.
    // 채식(vegetarian)이 아니면 eatsEggs/eatsDairy는 보내지 않습니다.
    // 닉네임 저장에 실패하면 ApiException을 던지고, 프로필도 저장하지 않습니다.
    if (state.isNicknameValid) {
      await ref.read(accountProvider.notifier).saveNickname(state.nickname);
    }
    ref
        .read(dietaryProfileProvider.notifier)
        .replace(
          DietaryProfile(
            allergies: state.allergies,
            diet: state.diet ?? DietType.noParticularDiet,
            eatsEggs: state.eatsEggs,
            eatsDairy: state.eatsDairy,
          ),
        );
  }

  /// 온보딩을 마치면 입력값을 비웁니다.
  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

/// 알레르기 검색 대상 목록입니다.
// TODO: 알레르기 검색 API(GET /api/ingredients/search)를 연결하면 삭제합니다.
// ingredientId는 화면 확인용 임시 값이라 서버 성분 id와 다릅니다.
const List<AllergenItem> onboardingAllergyCatalog = [
  AllergenItem(ingredientId: 1, nameKo: '새우', nameEn: 'Shrimp'),
  AllergenItem(ingredientId: 2, nameKo: '대하', nameEn: 'Prawn'),
  AllergenItem(ingredientId: 3, nameKo: '게', nameEn: 'Crab'),
  AllergenItem(ingredientId: 4, nameKo: '랍스터', nameEn: 'Lobster'),
  AllergenItem(ingredientId: 5, nameKo: '오징어', nameEn: 'Squid'),
  AllergenItem(ingredientId: 6, nameKo: '조개', nameEn: 'Clam'),
  AllergenItem(ingredientId: 7, nameKo: '굴', nameEn: 'Oyster'),
  AllergenItem(ingredientId: 8, nameKo: '홍합', nameEn: 'Mussel'),
  AllergenItem(ingredientId: 9, nameKo: '전복', nameEn: 'Abalone'),
  AllergenItem(ingredientId: 10, nameKo: '멸치', nameEn: 'Anchovy'),
  AllergenItem(ingredientId: 11, nameKo: '고등어', nameEn: 'Mackerel'),
  AllergenItem(ingredientId: 12, nameKo: '계란', nameEn: 'Egg'),
  AllergenItem(ingredientId: 13, nameKo: '우유', nameEn: 'Milk'),
  AllergenItem(ingredientId: 14, nameKo: '밀', nameEn: 'Wheat'),
  AllergenItem(ingredientId: 15, nameKo: '메밀', nameEn: 'Buckwheat'),
  AllergenItem(ingredientId: 16, nameKo: '대두', nameEn: 'Soybean'),
  AllergenItem(ingredientId: 17, nameKo: '땅콩', nameEn: 'Peanut'),
  AllergenItem(ingredientId: 18, nameKo: '호두', nameEn: 'Walnut'),
  AllergenItem(ingredientId: 19, nameKo: '잣', nameEn: 'Pine nut'),
  AllergenItem(ingredientId: 20, nameKo: '참깨', nameEn: 'Sesame'),
  AllergenItem(ingredientId: 21, nameKo: '복숭아', nameEn: 'Peach'),
  AllergenItem(ingredientId: 22, nameKo: '토마토', nameEn: 'Tomato'),
  AllergenItem(ingredientId: 23, nameKo: '돼지고기', nameEn: 'Pork'),
  AllergenItem(ingredientId: 24, nameKo: '소고기', nameEn: 'Beef'),
  AllergenItem(ingredientId: 25, nameKo: '닭고기', nameEn: 'Chicken'),
];
