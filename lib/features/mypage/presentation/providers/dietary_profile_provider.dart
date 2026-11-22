import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/presentation/providers/onboarding_state.dart';
import '../../data/models/dietary_profile.dart';

// 이 파일을 import하던 곳이 그대로 DietaryProfile을 쓸 수 있도록 다시 내보냅니다.
export '../../data/models/dietary_profile.dart';

class DietaryProfileNotifier extends Notifier<DietaryProfile> {
  // TODO: 프로필 조회 API가 준비되면 서버 값으로 초기화합니다.
  @override
  DietaryProfile build() => const DietaryProfile(
    allergies: [
      AllergenItem(ingredientId: 1, nameKo: '새우', nameEn: 'Shrimp'),
      AllergenItem(ingredientId: 10, nameKo: '멸치', nameEn: 'Anchovy'),
      AllergenItem(ingredientId: 18, nameKo: '호두', nameEn: 'Walnut'),
    ],
  );

  /// 온보딩을 마치면 입력한 프로필 전체를 반영합니다.
  void replace(DietaryProfile profile) {
    state = profile.copyWith(allergies: List.unmodifiable(profile.allergies));
  }

  // TODO: 알레르기 수정 API를 연결합니다.
  void saveAllergies(List<AllergenItem> allergies) {
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
