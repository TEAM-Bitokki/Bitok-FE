import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_status_chip.dart';

/// 'Save to My Checks'로 저장한 메뉴 확인 결과 한 건입니다.
///
/// 홈의 Recent Checks와 마이페이지의 Saved Menus가 이 목록을 보여줍니다.
class MenuCheck {
  const MenuCheck({
    required this.id,
    required this.menuId,
    required this.koreanName,
    required this.englishName,
    required this.restaurantName,
    required this.status,
    required this.checkedAt,
    this.checkedIngredients = const [],
  });

  /// 확인 결과 한 건의 id입니다.
  final String id;

  /// 메뉴 상세('/menu/:id')로 이동할 때 쓰는 메뉴 id입니다.
  final String menuId;

  /// 사용자가 직접 추가한 메뉴는 비어 있을 수 있습니다.
  final String koreanName;
  final String englishName;
  final String restaurantName;
  final BitokMenuStatus status;
  final DateTime checkedAt;

  /// 직원에게 확인한 재료의 영문 이름입니다. 예: ['shrimp', 'anchovy']
  /// 메뉴 상세의 판정 카드에 표시합니다.
  final List<String> checkedIngredients;
}

/// 저장한 메뉴 확인 결과 목록입니다. 최근에 저장한 것이 앞에 옵니다.
class MyChecksNotifier extends Notifier<List<MenuCheck>> {
  int _nextId = 0;

  // TODO: My Checks 조회 API가 준비되면 서버 값으로 초기화합니다.
  @override
  List<MenuCheck> build() {
    final today = DateTime.now();
    return [
      _mock('bibimbap', '비빔밥', 'Bibimbap', BitokMenuStatus.safe, today, [
        'shrimp',
      ]),
      _mock(
        'kimchi-jjigae',
        '김치찌개',
        'Kimchi Jjigae',
        BitokMenuStatus.avoid,
        today,
        ['shrimp', 'anchovy'],
      ),
      _mock('bulgogi', '불고기', 'Bulgogi', BitokMenuStatus.notSure, today, [
        'meat',
      ]),
    ];
  }

  /// 확인 결과를 목록 맨 앞에 추가합니다.
  // TODO: 저장 API를 연결합니다.
  void addAll(List<MenuCheck> checks) {
    state = [...checks, ...state];
  }

  /// 새 확인 결과의 id를 만듭니다. (서버 연동 전 임시)
  String newId() => 'local-${_nextId++}';

  MenuCheck _mock(
    String menuId,
    String koreanName,
    String englishName,
    BitokMenuStatus status,
    DateTime checkedAt,
    List<String> checkedIngredients,
  ) {
    return MenuCheck(
      id: newId(),
      menuId: menuId,
      koreanName: koreanName,
      englishName: englishName,
      restaurantName: 'Myeongdong Kyoja',
      status: status,
      checkedAt: checkedAt,
      checkedIngredients: checkedIngredients,
    );
  }
}

final myChecksProvider = NotifierProvider<MyChecksNotifier, List<MenuCheck>>(
  MyChecksNotifier.new,
);
