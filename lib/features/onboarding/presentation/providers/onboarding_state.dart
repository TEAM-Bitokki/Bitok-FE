// presentation/providers: 온보딩 플로우 전체(닉네임 → 알레르기 → 식단 → 확인)에서
// 함께 쓰는 입력 상태를 정의합니다. 각 단계 화면은 별도 라우트이므로
// onboarding_provider.dart가 이 상태를 단계 간에 유지합니다.

import 'package:json_annotation/json_annotation.dart';

/// 식단 선택지입니다. 선택 전에는 [OnboardingState.diet]가 null입니다.
/// 서버 값(diet_type)과 같은 enum을 씁니다: none / vegan / vegetarian / pescatarian
enum DietType {
  @JsonValue('none')
  noParticularDiet,
  vegan,
  vegetarian,
  pescatarian,
}

class OnboardingState {
  const OnboardingState({
    this.nickname = '',
    this.allergies = const [],
    this.diet,
    this.eatsEggs = false,
    this.eatsDairy = false,
  });

  final String nickname;

  /// 선택한 순서를 유지합니다. 하단 칩도 이 순서로 표시됩니다.
  final List<String> allergies;

  final DietType? diet;

  /// [DietType.vegetarian]일 때만 의미가 있는 세부 옵션입니다.
  final bool eatsEggs;
  final bool eatsDairy;

  bool get isNicknameValid => nickname.trim().isNotEmpty;

  OnboardingState copyWith({
    String? nickname,
    List<String>? allergies,
    DietType? diet,
    bool? eatsEggs,
    bool? eatsDairy,
  }) {
    return OnboardingState(
      nickname: nickname ?? this.nickname,
      allergies: allergies ?? this.allergies,
      diet: diet ?? this.diet,
      eatsEggs: eatsEggs ?? this.eatsEggs,
      eatsDairy: eatsDairy ?? this.eatsDairy,
    );
  }
}
