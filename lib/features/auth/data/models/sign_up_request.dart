import 'package:json_annotation/json_annotation.dart';

part 'sign_up_request.g.dart';

// 요청 DTO 작성 예시:
// - @JsonSerializable(createFactory: false): 보내기만 하는 요청이라 fromJson은 만들지 않습니다.
// - includeIfNull: false: null인 필드는 body에서 뺍니다.
//
// POST /api/auth/sign-up 요청 body
@JsonSerializable(createFactory: false, includeIfNull: false)
class SignUpRequest {
  const SignUpRequest({required this.deviceToken, this.nickname});

  final String deviceToken;

  /// 최대 20자. 가입 시점에 없으면 온보딩에서 따로 저장합니다.
  final String? nickname;

  Map<String, dynamic> toJson() => _$SignUpRequestToJson(this);
}
