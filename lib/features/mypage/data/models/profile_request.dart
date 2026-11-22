import 'package:json_annotation/json_annotation.dart';

import '../../../../core/models/diet_option.dart';
import '../../../../core/models/diet_type.dart';

part 'profile_request.g.dart';

// PUT /api/profiles/me 요청 body. 온보딩과 수정 화면이 함께 씁니다.
// 서버는 프로필을 통째로 덮어쓰므로 항상 전체 값을 보냅니다.
@JsonSerializable(createFactory: false)
class ProfileRequest {
  const ProfileRequest({
    required this.allergenIngredientIds,
    required this.dietType,
    this.dietOptions = const [],
  });

  /// 알레르기 성분 id 목록 (최대 100개). 비어 있어도(Skip) 프로필이 생깁니다.
  /// 검색 목록에 없는 id면 서버가 400을 돌려줍니다.
  final List<int> allergenIngredientIds;

  final DietType dietType;

  /// [DietType.vegetarian]일 때만 서버에 저장됩니다.
  final List<DietOption> dietOptions;

  Map<String, dynamic> toJson() => _$ProfileRequestToJson(this);
}
