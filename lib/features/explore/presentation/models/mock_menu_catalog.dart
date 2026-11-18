// TODO: 메뉴 상세 API('/menus/:id') 연동 시 이 파일을 삭제합니다.
// 서버가 사용자 프로필 기준 판정과 재료를 내려주기 전까지 쓰는 임시 데이터입니다.
import '../../../../common/widgets/bitok_status_chip.dart';
import '../screens/menu_detail_screen.dart';

/// 영문 메뉴 이름으로 임시 메뉴 id를 만듭니다. 예: 'Kimchi Jjigae' → 'kimchi-jjigae'
///
/// 스캔한 메뉴처럼 아직 서버 id가 없는 메뉴에 씁니다.
/// 영문자·숫자가 없는 이름(예: '짜장면')은 메뉴끼리 id가 겹치지 않도록 이름을 그대로 씁니다.
String mockMenuIdOf(String englishName) {
  final name = englishName.trim();
  final slug = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  if (slug.isNotEmpty) return slug;
  return name.isEmpty ? 'menu' : name;
}

/// 메뉴 id로 상세 정보를 찾습니다.
///
/// 목록에 없는 메뉴(직접 추가한 메뉴 등)는 id에서 이름을 만들고 판정 카드 없이 보여줍니다.
/// [status]를 주면(저장한 확인 결과) 임시 카탈로그의 고정 판정보다 우선합니다.
MenuDetail findMockMenuDetail(String menuId, {BitokMenuStatus? status}) {
  final entry = _catalog[menuId];
  status ??= entry?.$2;
  return MenuDetail(
    englishName: entry?.$1 ?? _titleCase(menuId),
    avoidIngredients: status == BitokMenuStatus.avoid
        ? const ['Shrimp']
        : const [],
    notSureIngredients:
        status == BitokMenuStatus.avoid || status == BitokMenuStatus.notSure
        ? const ['Shrimp']
        : const [],
    commonIngredients: _commonIngredients,
  );
}

/// 메뉴 id → (영문 이름, 사용자 프로필 기준 판정)
const Map<String, (String, BitokMenuStatus)> _catalog = {
  'kimchi-jjigae': ('Kimchi Jjigae', BitokMenuStatus.avoid),
  'bibimbap': ('Bibimbap', BitokMenuStatus.safe),
  'bulgogi': ('Bulgogi', BitokMenuStatus.notSure),
};

const List<CommonIngredient> _commonIngredients = [
  CommonIngredient(category: 'Crustacean Shellfish', items: ['Salted shrimp']),
  CommonIngredient(category: 'Fish', items: ['Anchovy sauce', 'Anchovy broth']),
  CommonIngredient(category: 'Soybeans', items: ['Tofu', 'Soy sauce']),
  CommonIngredient(
    category: 'Wheat',
    items: ['Some soy sauces and seasonings'],
  ),
];

String _titleCase(String id) => id
    .split('-')
    .where((word) => word.isNotEmpty)
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');
