/// 메뉴판에서 인식한(또는 사용자가 추가한) 메뉴 한 개입니다.
class ScanMenuItem {
  const ScanMenuItem({
    required this.id,
    required this.koreanName,
    required this.englishName,
  });

  /// 목록 안에서 메뉴를 구분하는 값입니다.
  /// 인식한 메뉴는 서버의 temp_id(예: i1)를 그대로 쓰고, analyze 요청의 temp_id로 보냅니다.
  final String id;

  /// 메뉴판에 적힌 이름(raw_name)입니다. 사용자가 직접 추가한 메뉴는 비어 있을 수 있습니다.
  final String koreanName;

  /// 사용자에게 보여주는 영문 이름입니다.
  final String englishName;

  ScanMenuItem copyWith({String? koreanName, String? englishName}) {
    return ScanMenuItem(
      id: id,
      koreanName: koreanName ?? this.koreanName,
      englishName: englishName ?? this.englishName,
    );
  }
}
