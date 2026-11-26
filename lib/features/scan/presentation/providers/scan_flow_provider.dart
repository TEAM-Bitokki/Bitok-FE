import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../explore/presentation/models/mock_menu_catalog.dart';
import '../../../mypage/presentation/providers/my_checks_provider.dart';
import '../../data/models/scan_menu_item.dart';
import '../../data/models/scan_restaurant.dart';
import '../../data/models/staff_question.dart';
import '../../data/repositories/scan_repository.dart';
import 'scan_flow_state.dart';

/// 메뉴 스캔 플로우의 상태(이미지, 인식한 메뉴 목록, 선택한 메뉴)를 관리합니다.
class ScanFlowNotifier extends Notifier<ScanFlowState> {
  int _nextId = 0;

  /// 가장 최근에 인식을 요청한 이미지 경로입니다. 늦게 도착한 이전 응답을 버릴 때 씁니다.
  String? _recognizingPath;

  @override
  ScanFlowState build() => const ScanFlowState();

  /// 이전 스캔 결과를 모두 지웁니다. 새 스캔 플로우를 시작할 때 호출합니다.
  void reset() => state = const ScanFlowState();

  /// REST-01에서 고른 식당으로 새 스캔 플로우를 시작합니다. 이전 스캔 결과는 지웁니다.
  void start(ScanRestaurant restaurant) =>
      state = ScanFlowState(restaurant: restaurant);

  /// 메뉴판 이미지를 서버(POST /api/scans)에 올려 메뉴를 인식합니다. 10~25초 걸립니다.
  ///
  /// 이미 인식한 이미지와 같으면 다시 인식하지 않아, REST-04에서 고친 목록이 유지됩니다.
  /// (REST-04 → REST-03으로 돌아갔다가 다시 Next를 누르는 경우)
  /// 다른 이미지면 이전 스캔 결과를 지우고 새로 인식합니다.
  ///
  /// 실패하면 상태를 바꾸지 않고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> recognize(String imagePath) async {
    if (state.imagePath == imagePath && state.scanId != null) return;

    _recognizingPath = imagePath;
    final restaurant = state.restaurant;
    final response = await ref
        .read(scanRepositoryProvider)
        .createScan(
          imagePath: imagePath,
          restaurantId: restaurant?.restaurantId,
        );
    // 기다리는 동안 다른 사진으로 다시 인식했거나 새 스캔을 시작했으면 이 응답은 버립니다.
    if (!ref.mounted ||
        _recognizingPath != imagePath ||
        !identical(state.restaurant, restaurant)) {
      return;
    }

    state = ScanFlowState(
      restaurant: restaurant,
      imagePath: imagePath,
      scanId: response.scanId,
      items: [
        for (final item in response.items)
          ScanMenuItem(
            id: item.tempId,
            koreanName: item.rawName,
            englishName: item.nameEn ?? item.rawName,
          ),
      ],
    );
  }

  /// 메뉴 이름(영문)을 바꿉니다.
  void renameItem(String id, String englishName) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          item.id == id ? item.copyWith(englishName: englishName) : item,
      ],
    );
  }

  /// 메뉴를 목록에서 지웁니다. 선택되어 있었다면 선택도 해제합니다.
  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
      selectedIds: {...state.selectedIds}..remove(id),
    );
  }

  /// REST-05에서 메뉴 선택 여부를 바꿉니다.
  void toggleSelection(String id) {
    final selectedIds = {...state.selectedIds};
    if (!selectedIds.remove(id)) selectedIds.add(id);
    state = state.copyWith(selectedIds: selectedIds);
  }

  /// 인식되지 않은 메뉴를 직접 추가합니다.
  void addItem(String englishName) {
    state = state.copyWith(
      items: [
        ...state.items,
        _newItem(koreanName: '', englishName: englishName),
      ],
    );
  }

  /// REST-05에서 고른 메뉴를 분석해 직원에게 확인할 질문을 만듭니다.
  ///
  /// 고른 메뉴마다 질문이 한 개씩 만들어집니다(고르지 않은 메뉴는 질문하지 않습니다).
  /// 이미 답한 메뉴의 답변은 유지합니다.
  /// (REST-06 → REST-05로 돌아가 선택을 바꾼 뒤 다시 Next를 누르는 경우)
  Future<void> analyze() async {
    // TODO: 메뉴 분석 API를 연결하면 응답으로 메뉴별 확인할 재료를 채웁니다.
    // 연동 전까지는 임시 데이터(_mockIngredientsToCheck)로 질문을 만듭니다.
    final questions = [
      for (final item in state.selectedItems)
        StaffQuestion(
          itemId: item.id,
          // 직접 추가한 메뉴는 한글 이름이 없어서 입력한 이름으로 질문합니다.
          menuKoreanName: item.koreanName.isEmpty
              ? item.englishName
              : item.koreanName,
          menuEnglishName: item.englishName,
          ingredients:
              _mockIngredientsToCheck[item.koreanName] ??
              _mockDefaultIngredients,
        ),
    ];
    final questionIds = questions.map((question) => question.id).toSet();
    state = state.copyWith(
      questions: questions,
      answers: Map.fromEntries(
        state.answers.entries.where((e) => questionIds.contains(e.key)),
      ),
    );
  }

  /// REST-06에서 직원의 답변을 기록합니다.
  void answer(String questionId, StaffAnswer answer) {
    state = state.copyWith(answers: {...state.answers, questionId: answer});
  }

  /// REST-07 결과를 My Checks에 저장합니다.
  ///
  /// 고른 메뉴마다 확인 결과가 한 건씩 저장되어 홈 Recent Checks와 Saved Menus에 나타납니다.
  /// 이미 저장한 결과를 다시 저장하면(REST-08 → REST-07로 돌아온 경우) 중복으로 추가하지 않습니다.
  Future<void> save() async {
    if (state.savedAt != null) return;
    // TODO: 저장 API를 연결합니다.
    final checks = ref.read(myChecksProvider.notifier);
    final now = DateTime.now();
    checks.addAll([
      for (final item in state.selectedItems)
        MenuCheck(
          id: checks.newId(),
          // TODO: 메뉴 분석 API가 메뉴 id를 주면 그 값을 씁니다.
          menuId: mockMenuIdOf(item.englishName),
          koreanName: item.koreanName,
          englishName: item.englishName,
          restaurantName: state.restaurant?.name ?? '',
          status: state.statusOf(item.id),
          checkedAt: now,
          checkedIngredients: state.checkedIngredientsOf(item.id),
        ),
    ]);
    state = state.copyWith(savedAt: now);
  }

  ScanMenuItem _newItem({
    required String koreanName,
    required String englishName,
  }) {
    return ScanMenuItem(
      // 서버 temp_id(i1, i2, ...)와 겹치지 않도록 접두어를 다르게 둡니다.
      id: 'm${_nextId++}',
      koreanName: koreanName,
      englishName: englishName,
    );
  }
}

final scanFlowProvider = NotifierProvider<ScanFlowNotifier, ScanFlowState>(
  ScanFlowNotifier.new,
);

// TODO: 메뉴 분석 API 연동 후 삭제합니다. 메뉴(한글 이름)별로 직원에게 확인할 재료입니다.
const Map<String, List<StaffCheckIngredient>> _mockIngredientsToCheck = {
  '김치찌개': [
    StaffCheckIngredient(koreanName: '새우', englishName: 'shrimp'),
    StaffCheckIngredient(koreanName: '멸치', englishName: 'anchovy'),
  ],
  '불고기': [StaffCheckIngredient(koreanName: '고기', englishName: 'meat')],
};

// TODO: 메뉴 분석 API 연동 후 삭제합니다.
// 위 표에 없는 메뉴(직접 추가한 메뉴 포함)에 쓰는 기본 재료입니다.
const List<StaffCheckIngredient> _mockDefaultIngredients = [
  StaffCheckIngredient(koreanName: '새우', englishName: 'shrimp'),
];
