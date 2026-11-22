import 'package:json_annotation/json_annotation.dart';

part 'allergen_item.g.dart';

// 여러 feature(온보딩, 마이페이지)가 함께 쓰는 알레르기 성분입니다.
// GET /api/profiles/me 의 allergens 항목과 같은 형태입니다.
// 프로필을 저장할 때는 ingredientId만 서버로 보냅니다 (allergen_ingredient_ids).
@JsonSerializable(createToJson: false)
class AllergenItem {
  const AllergenItem({
    required this.ingredientId,
    required this.nameKo,
    required this.nameEn,
  });

  final int ingredientId;
  final String nameKo;
  final String nameEn;

  /// 화면에 표시하는 이름입니다. 앱 UI가 영어 기준이라 영문 이름을 씁니다.
  String get label => nameEn;

  factory AllergenItem.fromJson(Map<String, dynamic> json) =>
      _$AllergenItemFromJson(json);

  // 선택 여부(contains)와 토글을 id로 비교합니다.
  @override
  bool operator ==(Object other) =>
      other is AllergenItem && other.ingredientId == ingredientId;

  @override
  int get hashCode => ingredientId.hashCode;
}
