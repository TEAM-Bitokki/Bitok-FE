import 'package:json_annotation/json_annotation.dart';

part 'nickname_request.g.dart';

// PATCH /api/users/me 요청 body
@JsonSerializable(createFactory: false)
class NicknameRequest {
  const NicknameRequest({required this.nickname});

  /// 최대 20자.
  final String nickname;

  Map<String, dynamic> toJson() => _$NicknameRequestToJson(this);
}
