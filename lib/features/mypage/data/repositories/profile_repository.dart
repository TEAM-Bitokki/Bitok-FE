import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/diet_option.dart';
import '../../../../core/models/diet_type.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_code.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/dietary_profile.dart';
import '../models/ingredient_item.dart';
import '../models/profile_request.dart';
import '../models/profile_response.dart';

// 식단 프로필 조회·저장과 알레르기 성분 검색을 맡습니다.
// 서버 DTO(diet_options, allergen_ingredient_ids)와 앱 모델(DietaryProfile)의 변환을
// 이곳에서만 하므로, 화면과 provider는 서버 형식을 몰라도 됩니다.
class ProfileRepository {
  ProfileRepository(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  /// 내 식단 프로필입니다. 아직 등록하지 않았으면(404) null을 돌려줍니다.
  ///
  /// 그 밖의 실패는 ApiException 그대로 던집니다.
  Future<DietaryProfile?> getProfile() async {
    try {
      return _toProfile(await _remoteDataSource.getProfile());
    } on ApiException catch (e) {
      if (e.code == ErrorCode.notFound) return null;
      rethrow;
    }
  }

  /// 프로필 전체를 저장(덮어쓰기)하고, 서버에 저장된 프로필을 돌려줍니다.
  /// 온보딩 완료와 마이페이지 수정이 모두 이 메서드를 씁니다.
  Future<DietaryProfile> saveProfile(DietaryProfile profile) async {
    final response = await _remoteDataSource.putProfile(_toRequest(profile));
    return _toProfile(response);
  }

  /// 알레르기 성분을 검색합니다. 빈 검색어면 전체 목록입니다.
  ///
  /// 별칭(matchedAlias)을 화면에 보여줄 수 있도록 검색 결과 항목을 그대로 돌려줍니다.
  /// 선택한 항목은 [IngredientItem.toAllergen]으로 바꿔 상태에 담으세요.
  Future<List<IngredientItem>> searchAllergens(
    String query, {
    int? limit,
  }) async {
    final response = await _remoteDataSource.searchIngredients(
      query: query,
      limit: limit,
    );
    return response.items;
  }

  static ProfileRequest _toRequest(DietaryProfile profile) {
    final isVegetarian = profile.diet == DietType.vegetarian;
    return ProfileRequest(
      allergenIngredientIds: [
        for (final allergy in profile.allergies) allergy.ingredientId,
      ],
      dietType: profile.diet,
      // 서버는 vegetarian일 때만 저장하므로, 그 밖의 식단이면 보내지 않습니다.
      dietOptions: [
        if (isVegetarian && profile.eatsEggs) DietOption.eatsEgg,
        if (isVegetarian && profile.eatsDairy) DietOption.eatsDairy,
      ],
    );
  }

  static DietaryProfile _toProfile(ProfileResponse response) {
    final diet = response.dietType;
    // 앱이 모르는 식단을 'none'으로 바꾸면, 다음 저장 때 서버 값을 덮어쓰게 됩니다.
    // 그래서 기본값으로 바꾸지 않고 형식 오류로 처리합니다. (앱 업데이트가 필요한 경우)
    if (diet == null) {
      throw const ApiException(
        code: ErrorCode.invalidResponse,
        message: '앱이 지원하지 않는 식단 유형입니다.',
      );
    }
    final isVegetarian = diet == DietType.vegetarian;
    return DietaryProfile(
      allergies: List.unmodifiable(response.allergens),
      diet: diet,
      eatsEggs:
          isVegetarian && response.dietOptions.contains(DietOption.eatsEgg),
      eatsDairy:
          isVegetarian && response.dietOptions.contains(DietOption.eatsDairy),
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(profileRemoteDataSourceProvider));
});
