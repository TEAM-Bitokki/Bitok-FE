import 'package:json_annotation/json_annotation.dart';

part 'delete_account_request.g.dart';

// DELETE /api/users/me 요청 body
@JsonSerializable(createFactory: false)
class DeleteAccountRequest {
  const DeleteAccountRequest({
    required this.agree,
    this.deleteSavedMenus = false,
  });

  /// 탈퇴 재확인. false면 서버가 400(VALIDATION_ERROR)을 돌려줍니다.
  final bool agree;

  /// false: 분석 기록을 익명화해 남깁니다 (식당 상세·지도에 계속 반영).
  /// true: 저장한 메뉴와 분석 기록까지 삭제합니다.
  final bool deleteSavedMenus;

  Map<String, dynamic> toJson() => _$DeleteAccountRequestToJson(this);
}
