import 'package:json_annotation/json_annotation.dart';

// Vegetarian 하위 선택입니다. 서버 값(diet_options)과 같은 enum을 씁니다.
// 서버는 diet_type이 vegetarian일 때만 이 값을 저장합니다.
enum DietOption {
  @JsonValue('eats_egg')
  eatsEgg,
  @JsonValue('eats_dairy')
  eatsDairy,
}
