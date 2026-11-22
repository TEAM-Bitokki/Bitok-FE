import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/account_provider.dart';
import '../../../mypage/data/repositories/profile_repository.dart';
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

  /// 입력한 닉네임(PATCH /api/users/me)과 식단 프로필(PUT /api/profiles/me)을
  /// 차례로 저장합니다.
  ///
  /// 하나라도 실패하면 ApiException을 던집니다. 닉네임 저장에 실패하면 프로필은 보내지 않습니다.
  /// 두 요청 모두 같은 값을 다시 보내도 결과가 같으므로, 실패하면 처음부터 다시 호출하면 됩니다.
  /// diet_options 변환(채식이 아니면 보내지 않음)은 ProfileRepository가 맡습니다.
  Future<void> submit() async {
    // 저장을 기다리는 동안 입력이 바뀌어도, 제출한 시점의 값만 저장합니다.
    final draft = state;
    if (draft.isNicknameValid) {
      await ref.read(accountProvider.notifier).saveNickname(draft.nickname);
    }
    await ref
        .read(profileRepositoryProvider)
        .saveProfile(
          DietaryProfile(
            allergies: draft.allergies,
            diet: draft.diet ?? DietType.noParticularDiet,
            eatsEggs: draft.eatsEggs,
            eatsDairy: draft.eatsDairy,
          ),
        );
    // 이미 불러온 프로필이 있으면 저장된 값으로 다시 불러옵니다. (아직 안 불러왔으면 아무 일도 없습니다)
    ref.invalidate(dietaryProfileProvider);
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
