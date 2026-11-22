import 'package:json_annotation/json_annotation.dart';

import '../../../../core/models/allergen_item.dart';
import '../../../../core/models/diet_option.dart';
import '../../../../core/models/diet_type.dart';

part 'profile_response.g.dart';

// GET /api/profiles/me, PUT /api/profiles/me 응답
@JsonSerializable(createToJson: false)
class ProfileResponse {
  const ProfileResponse({
    required this.allergens,
    required this.dietType,
    this.dietOptions = const [],
  });

  final List<AllergenItem> allergens;

  /// 서버에 새 식단 값이 추가돼도 앱이 죽지 않도록 모르는 값은 null로 받습니다.
  /// null을 어떤 값으로 다룰지는 repository에서 정합니다.
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final DietType? dietType;

  final List<DietOption> dietOptions;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
}
