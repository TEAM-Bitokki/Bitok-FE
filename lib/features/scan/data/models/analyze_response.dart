import 'package:json_annotation/json_annotation.dart';

import 'analyzed_menu.dart';

part 'analyze_response.g.dart';

/// POST /api/scans/{scan_id}/analyze 응답.
@JsonSerializable(createToJson: false)
class AnalyzeResponse {
  const AnalyzeResponse({required this.menus, required this.questions});

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalyzeResponseFromJson(json);

  final List<AnalyzedMenu> menus;

  /// 0~5개. 비어 있으면 질문 화면(REST-06)을 건너뛰고 바로 결과로 갑니다.
  final List<StaffQuestionResponse> questions;
}

/// 직원에게 확인할 질문 한 개입니다. 확인이 필요한 재료에 대해서만 만들어집니다.
@JsonSerializable(createToJson: false)
class StaffQuestionResponse {
  const StaffQuestionResponse({
    required this.questionId,
    required this.seq,
    required this.total,
    required this.dishId,
    required this.ingredientId,
    required this.questionKo,
    required this.questionEn,
  });

  factory StaffQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffQuestionResponseFromJson(json);

  /// POST /api/scans/{scan_id}/answers에 씁니다.
  final int questionId;

  /// 1부터 시작하는 순서와 전체 개수. 예: 1/3
  final int seq;
  final int total;

  final int dishId;
  final int ingredientId;

  /// 예: 이 김치찌개에 새우가 들어가나요?
  final String questionKo;

  /// 예: Does this kimchi jjigae contain shrimp?
  final String questionEn;
}
