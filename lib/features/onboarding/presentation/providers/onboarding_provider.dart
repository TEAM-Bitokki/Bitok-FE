import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_state.dart';

// presentation/providers: 온보딩 단계별 입력을 모아두고, 마지막에 서버로 저장합니다.
// 각 단계 화면(presentation/screens)은 이 provider만 watch/read 합니다.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  void toggleAllergy(String allergy) {
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

  /// 입력한 프로필을 저장합니다.
  Future<void> submit() async {
    // TODO: 온보딩 저장 API가 준비되면 repository를 통해 state를 전송합니다.
    // 채식(vegetarian)이 아니면 eatsEggs/eatsDairy는 보내지 않습니다.
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
// TODO: 알레르기 목록 API가 준비되면 서버 응답으로 교체합니다.
const List<String> onboardingAllergyCatalog = [
  'Shrimp',
  'Prawn',
  'Crab',
  'Lobster',
  'Squid',
  'Clam',
  'Oyster',
  'Mussel',
  'Abalone',
  'Anchovy',
  'Mackerel',
  'Egg',
  'Milk',
  'Wheat',
  'Buckwheat',
  'Soybean',
  'Peanut',
  'Walnut',
  'Pine nut',
  'Sesame',
  'Peach',
  'Tomato',
  'Pork',
  'Beef',
  'Chicken',
];
