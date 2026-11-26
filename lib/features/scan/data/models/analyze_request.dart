import 'package:json_annotation/json_annotation.dart';

part 'analyze_request.g.dart';

/// POST /api/scans/{scan_id}/analyze 요청 body.
///
/// [items]는 사용자가 수정·추가·삭제를 마친 화면의 전체 목록이고,
/// [selectedTempIds]는 그중 분석할 항목입니다(1개 이상).
@JsonSerializable(createFactory: false)
class AnalyzeRequest {
  const AnalyzeRequest({required this.items, required this.selectedTempIds});

  /// 최대 100개.
  final List<AnalyzeItem> items;

  /// 1~100개. [items]에 없는 temp_id면 서버가 400(VALIDATION_ERROR)을 돌려줍니다.
  final List<String> selectedTempIds;

  Map<String, dynamic> toJson() => _$AnalyzeRequestToJson(this);
}

@JsonSerializable(createFactory: false)
class AnalyzeItem {
  const AnalyzeItem({required this.tempId, required this.rawName});

  /// 1~20자. 서버가 준 값이 아니어도(직접 추가한 메뉴) 목록 안에서 겹치지만 않으면 됩니다.
  final String tempId;

  /// 1~100자.
  final String rawName;

  Map<String, dynamic> toJson() => _$AnalyzeItemToJson(this);
}
