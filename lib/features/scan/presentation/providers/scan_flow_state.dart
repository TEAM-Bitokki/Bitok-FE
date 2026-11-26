import '../../../../common/widgets/bitok_status_chip.dart';
import '../../../explore/presentation/models/menu_verdict.dart';
import '../../data/models/analyzed_menu.dart';
import '../../data/models/scan_menu_item.dart';
import '../../data/models/scan_restaurant.dart';
import '../../data/models/staff_question.dart';

/// 메뉴 스캔 플로우(REST-02 ~ REST-08) 동안 화면끼리 공유하는 상태입니다.
class ScanFlowState {
  const ScanFlowState({
    this.restaurant,
    this.imagePath,
    this.scanId,
    this.items = const [],
    this.selectedIds = const {},
    this.menus = const [],
    this.questions = const [],
    this.answers = const {},
    this.savedAt,
  });

  /// REST-01에서 고른 식당입니다. 저장한 확인 결과에 식당 이름으로 남습니다.
  final ScanRestaurant? restaurant;

  /// 스캔한 메뉴판 이미지 경로입니다.
  final String? imagePath;

  /// POST /api/scans가 돌려준 스캔 id입니다. 분석·응답·결과 요청에 씁니다. 인식 전에는 null입니다.
  final int? scanId;

  /// 인식한 메뉴 목록입니다. REST-04에서 수정/추가/삭제할 수 있습니다.
  final List<ScanMenuItem> items;

  /// REST-05에서 분석하려고 고른 메뉴의 id입니다.
  final Set<String> selectedIds;

  /// 서버가 분석한 메뉴별 판정입니다. REST-07에 이 목록을 보여줍니다.
  final List<AnalyzedMenu> menus;

  /// REST-06에서 직원에게 확인할 질문 목록입니다. 비어 있으면 REST-06을 건너뜁니다.
  final List<StaffQuestion> questions;

  /// 질문 id([StaffQuestion.id])별 직원 답변입니다.
  final Map<int, StaffAnswer> answers;

  /// REST-07에서 결과를 저장한 시각입니다. 저장 전에는 null입니다.
  final DateTime? savedAt;

  /// [selectedIds]에 해당하는 메뉴를 목록 순서대로 반환합니다.
  List<ScanMenuItem> get selectedItems =>
      items.where((item) => selectedIds.contains(item.id)).toList();

  /// REST-07에 표시할 메뉴의 판정 결과입니다. 서버 verdict를 그대로 씁니다.
  BitokMenuStatus statusOf(AnalyzedMenu menu) =>
      menuStatusOfVerdict(menu.verdict);

  /// 메뉴에서 걸린 재료의 영문 이름입니다. 메뉴 상세의 판정 카드에 표시합니다.
  List<String> checkedIngredientsOf(AnalyzedMenu menu) => [
    for (final match in menu.matches) match.ingredientEn,
  ];

  /// 예: '3 menu items checked'
  String get checkedLabel => menus.length == 1
      ? '1 menu item checked'
      : '${menus.length} menu items checked';

  /// 예: '3 menu items recognized'
  String get recognizedLabel => items.length == 1
      ? '1 menu item recognized'
      : '${items.length} menu items recognized';

  ScanFlowState copyWith({
    ScanRestaurant? restaurant,
    String? imagePath,
    int? scanId,
    List<ScanMenuItem>? items,
    Set<String>? selectedIds,
    List<AnalyzedMenu>? menus,
    List<StaffQuestion>? questions,
    Map<int, StaffAnswer>? answers,
    DateTime? savedAt,
  }) {
    return ScanFlowState(
      restaurant: restaurant ?? this.restaurant,
      imagePath: imagePath ?? this.imagePath,
      scanId: scanId ?? this.scanId,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      menus: menus ?? this.menus,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
