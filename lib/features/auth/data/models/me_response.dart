import 'package:json_annotation/json_annotation.dart';

import '../../../../core/models/diet_type.dart';

part 'me_response.g.dart';

// data/models: 서버 응답(JSON)을 앱에서 다루는 객체로 매핑하는 데이터 모델입니다.
//
// 응답 DTO 작성 예시:
// - @JsonSerializable(createToJson: false): 받기만 하는 응답이라 toJson은 만들지 않습니다.
// - 필드는 camelCase로 쓰면 build.yaml 설정으로 snake_case 키에 자동 매핑됩니다.
// - 수정 후 `dart run build_runner build -d`로 me_response.g.dart를 다시 만드세요.
//
// GET /api/auth/me, POST /api/auth/sign-up, PATCH /api/users/me 응답
@JsonSerializable(createToJson: false)
class MeResponse {
  const MeResponse({
    required this.userId,
    required this.hasProfile,
    this.nickname,
    this.dietType,
    this.allergenCount = 0,
  });

  final int userId;
  final String? nickname;

  /// false면 식이 프로필이 없으므로 온보딩으로 보냅니다.
  final bool hasProfile;

  /// 서버에 새 식단 값이 추가돼도 앱이 죽지 않도록 모르는 값은 null로 받습니다.
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final DietType? dietType;

  final int allergenCount;

  factory MeResponse.fromJson(Map<String, dynamic> json) =>
      _$MeResponseFromJson(json);
}
