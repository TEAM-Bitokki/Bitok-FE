import 'package:json_annotation/json_annotation.dart';

part 'my_check_item.g.dart';

/// GET /api/my-checks의 항목 한 개. 'Save to My Checks'로 저장한 메뉴입니다.
///
/// 홈 Recent Checks와 마이페이지 Saved Menus가 이 목록을 보여줍니다.
@JsonSerializable(createToJson: false)
class MyCheckItem {
  const MyCheckItem({
    required this.myCheckId,
    required this.analysisId,
    required this.dishId,
    required this.nameKo,
    required this.nameEn,
    required this.verdict,
    required this.savedAt,
    this.restaurantId,
    this.restaurantName,
  });

  factory MyCheckItem.fromJson(Map<String, dynamic> json) =>
      _$MyCheckItemFromJson(json);

  final int myCheckId;

  /// 메뉴 상세(GET /api/analyses/{analysis_id})를 열 때 씁니다.
  final int analysisId;

  final int dishId;
  final String nameKo;
  final String nameEn;
  final int? restaurantId;
  final String? restaurantName;

  /// avoid, safe, not_sure 중 하나. 현재 프로필 기준으로 다시 계산한 값이라
  /// 알레르기를 바꾸면 저장할 때와 달라질 수 있습니다.
  final String verdict;

  /// 예: 2026-11-01T11:30:00+09:00
  final DateTime savedAt;
}
