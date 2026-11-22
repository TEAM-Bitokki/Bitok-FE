import 'package:json_annotation/json_annotation.dart';

import '../../../../core/models/allergen_item.dart';

part 'ingredient_item.g.dart';

// GET /api/ingredients/search 응답의 항목입니다.
@JsonSerializable(createToJson: false)
class IngredientItem {
  const IngredientItem({
    required this.ingredientId,
    required this.nameKo,
    required this.nameEn,
    this.matchedAlias,
  });

  final int ingredientId;
  final String nameKo;
  final String nameEn;

  /// 별칭으로 찾았을 때 그 별칭입니다. 예: '달걀'로 검색 → 계란(matchedAlias: '달걀')
  final String? matchedAlias;

  /// 선택한 알레르기로 상태에 담을 때 씁니다.
  AllergenItem toAllergen() =>
      AllergenItem(ingredientId: ingredientId, nameKo: nameKo, nameEn: nameEn);

  factory IngredientItem.fromJson(Map<String, dynamic> json) =>
      _$IngredientItemFromJson(json);
}

// GET /api/ingredients/search 응답. 페이지 정보 없이 items만 옵니다.
@JsonSerializable(createToJson: false)
class IngredientSearchResponse {
  const IngredientSearchResponse({required this.items});

  final List<IngredientItem> items;

  factory IngredientSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$IngredientSearchResponseFromJson(json);
}
