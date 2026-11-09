/// 메뉴판에서 인식한(또는 사용자가 추가한) 메뉴 한 개입니다.
class ScanMenuItem {
  const ScanMenuItem({
    required this.id,
    required this.koreanName,
    required this.englishName,
  });

  /// 목록 안에서 메뉴를 구분하는 값입니다.
  final String id;

  /// 메뉴판에 적힌 한글 이름입니다. 사용자가 직접 추가한 메뉴는 비어 있을 수 있습니다.
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
