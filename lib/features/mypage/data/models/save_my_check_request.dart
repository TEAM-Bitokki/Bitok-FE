import 'package:json_annotation/json_annotation.dart';

part 'save_my_check_request.g.dart';

/// POST /api/my-checks 요청 body. 그 스캔에서 분석한 메뉴를 전부 저장합니다.
/// 같은 스캔을 다시 저장하면 서버가 그대로 둡니다(중복 저장되지 않음).
@JsonSerializable(createFactory: false)
class SaveMyCheckRequest {
  const SaveMyCheckRequest({required this.scanId});

  final int scanId;

  Map<String, dynamic> toJson() => _$SaveMyCheckRequestToJson(this);
}
