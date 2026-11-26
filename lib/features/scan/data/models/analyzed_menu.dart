import 'package:json_annotation/json_annotation.dart';

part 'analyzed_menu.g.dart';

/// analyze·result 응답의 메뉴 한 개에 대한 판정입니다.
@JsonSerializable(createToJson: false)
class AnalyzedMenu {
  const AnalyzedMenu({
    required this.dishId,
    required this.nameKo,
    required this.nameEn,
    required this.analysisId,
    required this.verdict,
    this.matches = const [],
  });

  factory AnalyzedMenu.fromJson(Map<String, dynamic> json) =>
      _$AnalyzedMenuFromJson(json);

  final int dishId;
  final String nameKo;
  final String nameEn;

  /// GET /api/analyses/{analysis_id}, POST /api/my-checks에 씁니다.
  final int analysisId;

  /// avoid, safe, not_sure 중 하나. 화면 상태는 menuStatusOfVerdict로 바꿉니다.
  final String verdict;

  /// 걸린 재료만 옵니다.
  final List<ScanMenuMatch> matches;
}

/// 메뉴에서 걸린 재료 한 개입니다.
@JsonSerializable(createToJson: false)
class ScanMenuMatch {
  const ScanMenuMatch({
    required this.ingredient,
    required this.ingredientEn,
    required this.status,
    required this.likelihood,
    this.tag,
    this.tagEn,
    this.verdict,
  });

  factory ScanMenuMatch.fromJson(Map<String, dynamic> json) =>
      _$ScanMenuMatchFromJson(json);

  /// 예: 새우젓
  final String ingredient;

  /// 예: Salted Shrimp
  final String ingredientEn;

  /// 예: crustacean
  final String? tag;

  /// 예: Crustacean Shellfish
  final String? tagEn;

  /// 걸린 이유. allergy, avoid, allowed 중 하나.
  final String status;

  /// typical(보통 들어감), possible(들어갈 수도 있음) 중 하나.
  final String likelihood;

  /// 재료별 판정. avoid, safe, not_sure 중 하나이며 result 응답에서 채워집니다.
  final String? verdict;
}
