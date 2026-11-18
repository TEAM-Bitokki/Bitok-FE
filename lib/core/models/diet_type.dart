import 'package:json_annotation/json_annotation.dart';

// 여러 feature(온보딩, 마이페이지, auth 응답)가 함께 쓰는 식단 타입입니다.
// 서버 값(diet_type)과 같은 enum을 씁니다: none / vegan / vegetarian / pescatarian
enum DietType {
  @JsonValue('none')
  noParticularDiet,
  vegan,
  vegetarian,
  pescatarian,
}
