import '../../../../common/widgets/bitok_status_chip.dart';
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

  /// REST-06에서 직원에게 확인할 질문 목록입니다.
  final List<StaffQuestion> questions;

  /// 질문 id([StaffQuestion.id])별 직원 답변입니다.
  final Map<String, StaffAnswer> answers;

  /// REST-07에서 결과를 저장한 시각입니다. 저장 전에는 null입니다.
  final DateTime? savedAt;

  /// [selectedIds]에 해당하는 메뉴를 목록 순서대로 반환합니다.
  List<ScanMenuItem> get selectedItems =>
      items.where((item) => selectedIds.contains(item.id)).toList();

  /// REST-07에 표시할 메뉴의 판정 결과입니다.
  ///
  /// 직원 답변이 '들어가요'면 Avoid, '모르겠어요'면 Not Sure, '안 들어가요'면 Safe입니다.
  /// 아직 답하지 않은 메뉴는 Not Sure로 표시합니다.
  /// 메뉴에 대해 직원에게 확인한 재료의 영문 이름입니다. 질문하지 않은 메뉴는 비어 있습니다.
  List<String> checkedIngredientsOf(String itemId) => [
    for (final question in questions)
      if (question.itemId == itemId)
        for (final ingredient in question.ingredients) ingredient.englishName,
  ];

  BitokMenuStatus statusOf(String itemId) {
    return switch (answers[itemId]) {
      StaffAnswer.contains => BitokMenuStatus.avoid,
      StaffAnswer.notContains => BitokMenuStatus.safe,
      StaffAnswer.notSure || null => BitokMenuStatus.notSure,
    };
  }

  /// 예: '3 menu items checked'
  String get checkedLabel => selectedIds.length == 1
      ? '1 menu item checked'
      : '${selectedIds.length} menu items checked';

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
    List<StaffQuestion>? questions,
    Map<String, StaffAnswer>? answers,
    DateTime? savedAt,
  }) {
    return ScanFlowState(
      restaurant: restaurant ?? this.restaurant,
      imagePath: imagePath ?? this.imagePath,
      scanId: scanId ?? this.scanId,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}
