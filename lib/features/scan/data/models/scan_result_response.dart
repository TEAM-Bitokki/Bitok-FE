import 'package:json_annotation/json_annotation.dart';

import 'analyzed_menu.dart';

part 'scan_result_response.g.dart';

/// GET /api/scans/{scan_id}/result 응답. 직원 응답을 반영한 최종 판정입니다(REST-07).
///
/// 확인하지 않은 차단 성분이 남아 있으면 safe가 나오지 않고,
/// '모르겠어요'나 답하지 않은 질문은 not_sure가 됩니다.
@JsonSerializable(createToJson: false)
class ScanResultResponse {
  const ScanResultResponse({
    required this.scanId,
    required this.menus,
    required this.checkedAt,
    this.restaurantId,
    this.restaurantName,
  });

  factory ScanResultResponse.fromJson(Map<String, dynamic> json) =>
      _$ScanResultResponseFromJson(json);

  final int scanId;
  final int? restaurantId;
  final String? restaurantName;
  final List<AnalyzedMenu> menus;

  /// 예: 2026-11-01T11:30:00+09:00
  final DateTime checkedAt;
}
