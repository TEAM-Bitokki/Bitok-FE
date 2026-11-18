import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/presentation/providers/onboarding_state.dart';

/// 사용자의 식단 프로필(알레르기·식단)입니다.
///
/// 마이페이지와 Dietary Profile 화면의 요약이 이 값을 보여줍니다.
class DietaryProfile {
  const DietaryProfile({
    this.allergies = const [],
    this.diet = DietType.noParticularDiet,
    this.eatsEggs = false,
    this.eatsDairy = false,
  });

  final List<String> allergies;
  final DietType diet;

  /// [DietType.vegetarian]일 때만 의미가 있는 세부 옵션입니다.
  final bool eatsEggs;
  final bool eatsDairy;

  DietaryProfile copyWith({
    List<String>? allergies,
    DietType? diet,
    bool? eatsEggs,
    bool? eatsDairy,
  }) {
    return DietaryProfile(
      allergies: allergies ?? this.allergies,
      diet: diet ?? this.diet,
      eatsEggs: eatsEggs ?? this.eatsEggs,
      eatsDairy: eatsDairy ?? this.eatsDairy,
    );
  }
}

class DietaryProfileNotifier extends Notifier<DietaryProfile> {
  // TODO: 프로필 조회 API가 준비되면 서버 값으로 초기화합니다.
  @override
  DietaryProfile build() =>
      const DietaryProfile(allergies: ['Shrimp', 'Anchovy', 'Walnut']);

  /// 온보딩을 마치면 입력한 프로필 전체를 반영합니다.
  void replace(DietaryProfile profile) {
    state = profile.copyWith(allergies: List.unmodifiable(profile.allergies));
  }

  // TODO: 알레르기 수정 API를 연결합니다.
  void saveAllergies(List<String> allergies) {
    state = state.copyWith(allergies: List.unmodifiable(allergies));
  }

  // TODO: 식단 수정 API를 연결합니다.
  void saveDiet({
    required DietType diet,
    required bool eatsEggs,
    required bool eatsDairy,
  }) {
    state = state.copyWith(
      diet: diet,
      eatsEggs: eatsEggs,
      eatsDairy: eatsDairy,
    );
  }
}

final dietaryProfileProvider =
    NotifierProvider<DietaryProfileNotifier, DietaryProfile>(
      DietaryProfileNotifier.new,
    );
