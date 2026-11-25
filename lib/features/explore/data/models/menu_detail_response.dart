import 'package:json_annotation/json_annotation.dart';

part 'menu_detail_response.g.dart';

@JsonSerializable(createToJson: false)
class DishBrief {
  const DishBrief({required this.dishId, required this.nameKo, this.nameEn});

  factory DishBrief.fromJson(Map<String, dynamic> json) =>
      _$DishBriefFromJson(json);

  final int dishId;
  final String nameKo;
  final String? nameEn;
}

@JsonSerializable(createToJson: false)
class MenuMatch {
  const MenuMatch({
    required this.ingredient,
    required this.verdict,
    this.ingredientEn,
    this.tag,
    this.tagEn,
    this.status,
    this.likelihood,
  });

  factory MenuMatch.fromJson(Map<String, dynamic> json) =>
      _$MenuMatchFromJson(json);

  final String ingredient;
  final String? ingredientEn;
  final String? tag;
  final String? tagEn;
  final String? status;
  final String? likelihood;
  final String verdict;
}

@JsonSerializable(createToJson: false)
class CommonIngredientGroup {
  const CommonIngredientGroup({
    required this.tagEn,
    this.ingredients = const [],
  });

  factory CommonIngredientGroup.fromJson(Map<String, dynamic> json) =>
      _$CommonIngredientGroupFromJson(json);

  final String tagEn;
  final List<String> ingredients;
}

@JsonSerializable(createToJson: false)
class MenuDetailResponse {
  const MenuDetailResponse({
    required this.dish,
    required this.verdict,
    this.matches = const [],
    this.commonIngredients = const [],
  });

  factory MenuDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MenuDetailResponseFromJson(json);

  final DishBrief dish;
  final String verdict;
  final List<MenuMatch> matches;
  final List<CommonIngredientGroup> commonIngredients;
}