import 'package:json_annotation/json_annotation.dart';

part 'nickname_request.g.dart';

// PATCH /api/users/me 요청 body
@JsonSerializable(createFactory: false)
class NicknameRequest {
  const NicknameRequest({required this.nickname});

  /// 서버가 허용하는 닉네임 최대 글자 수입니다.
  static const maxLength = 20;

  /// 앞뒤 공백을 지운 닉네임이 [maxLength]보다 긴지 확인합니다.
  ///
  /// 서버(Python)와 같은 기준으로 셉니다: 유니코드 문자(code point) 하나를 1자로 셉니다.
  /// Dart의 String.length는 이모지 등을 2자로 셀 수 있어서 runes를 씁니다.
  static bool isTooLong(String nickname) =>
      nickname.trim().runes.length > maxLength;

  /// 최대 [maxLength]자.
  final String nickname;

  Map<String, dynamic> toJson() => _$NicknameRequestToJson(this);
}
