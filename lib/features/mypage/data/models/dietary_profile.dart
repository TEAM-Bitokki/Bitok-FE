import '../../../../core/models/allergen_item.dart';
import '../../../../core/models/diet_type.dart';

// 앱에서 쓰는 식단 프로필입니다. 서버 DTO(ProfileRequest/ProfileResponse)와의 변환은
// ProfileRepository가 맡고, 화면과 provider는 이 모델만 다룹니다.

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

  final List<AllergenItem> allergies;
  final DietType diet;

  /// [DietType.vegetarian]일 때만 의미가 있는 세부 옵션입니다.
  final bool eatsEggs;
  final bool eatsDairy;

  DietaryProfile copyWith({
    List<AllergenItem>? allergies,
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
