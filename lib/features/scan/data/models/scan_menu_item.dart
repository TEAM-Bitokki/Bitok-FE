/// 메뉴판에서 인식한(또는 사용자가 추가한) 메뉴 한 개입니다.
class ScanMenuItem {
  const ScanMenuItem({
    required this.id,
    required this.koreanName,
    required this.englishName,
    this.renamed = false,
  });

  /// 목록 안에서 메뉴를 구분하는 값입니다.
  /// 인식한 메뉴는 서버의 temp_id(예: i1)를 그대로 쓰고, analyze 요청의 temp_id로 보냅니다.
  final String id;

  /// 메뉴판에 적힌 이름(raw_name)입니다. 사용자가 직접 추가한 메뉴는 비어 있을 수 있습니다.
  final String koreanName;

  /// 사용자에게 보여주는 영문 이름입니다.
  final String englishName;

  /// REST-04에서 사용자가 이름을 고쳤으면 true입니다.
  /// OCR이 잘못 읽은 이름을 고친 것이므로, 분석에는 메뉴판 이름 대신 고친 이름을 보냅니다.
  final bool renamed;

  /// analyze 요청의 raw_name으로 보낼 이름입니다.
  /// 고쳤거나 직접 추가한 메뉴는 입력한 이름, 그 밖에는 메뉴판에서 읽은 이름입니다.
  String get nameForAnalysis =>
      renamed || koreanName.isEmpty ? englishName : koreanName;

  ScanMenuItem copyWith({
    String? koreanName,
    String? englishName,
    bool? renamed,
  }) {
    return ScanMenuItem(
      id: id,
      koreanName: koreanName ?? this.koreanName,
      englishName: englishName ?? this.englishName,
      renamed: renamed ?? this.renamed,
    );
  }
}
