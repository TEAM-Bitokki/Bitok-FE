import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../mypage/data/repositories/my_checks_repository.dart';
import '../../../mypage/presentation/providers/my_checks_provider.dart';
import '../../data/models/analyze_request.dart';
import '../../data/models/scan_menu_item.dart';
import '../../data/models/scan_restaurant.dart';
import '../../data/models/staff_question.dart';
import '../../data/repositories/scan_repository.dart';
import 'scan_flow_state.dart';

/// 메뉴 스캔 플로우의 상태(이미지, 인식한 메뉴 목록, 선택한 메뉴)를 관리합니다.
class ScanFlowNotifier extends Notifier<ScanFlowState> {
  /// 분석 요청에 보낼 수 있는 메뉴 목록의 최대 개수입니다(서버 제한).
  static const int maxItems = 100;

  int _nextId = 0;

  /// 가장 최근에 인식을 요청한 이미지 경로입니다. 늦게 도착한 이전 응답을 버릴 때 씁니다.
  String? _recognizingPath;

  /// 마지막으로 성공한 분석 요청입니다. 같은 요청을 다시 보내지 않을 때 씁니다.
  _AnalyzeRequestKey? _analyzedKey;

  /// 분석 요청을 시작할 때마다 1씩 늘어납니다. 가장 최근 요청의 응답만 반영할 때 씁니다.
  int _analyzeSeq = 0;

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

  /// 메뉴 이름(영문)을 바꿉니다. 이름이 실제로 바뀌면 분석에도 고친 이름을 보냅니다.
  void renameItem(String id, String englishName) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          item.id == id && item.englishName != englishName
              ? item.copyWith(englishName: englishName, renamed: true)
              : item,
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

  /// 메뉴를 더 추가할 수 있으면 true입니다. 목록이 [maxItems]개면 false입니다.
  bool get canAddItem => state.items.length < maxItems;

  /// 인식되지 않은 메뉴를 직접 추가합니다. 이미 [maxItems]개면 추가하지 않습니다.
  void addItem(String englishName) {
    if (!canAddItem) return;
    state = state.copyWith(
      items: [
        ...state.items,
        _newItem(koreanName: '', englishName: englishName),
      ],
    );
  }

  /// REST-05에서 고른 메뉴를 서버(POST /api/scans/{scan_id}/analyze)에서 분석합니다.
  ///
  /// 메뉴별 판정([ScanFlowState.menus])과 직원에게 확인할 질문(0~5개)을 받습니다.
  /// 목록과 선택이 지난번 분석과 같으면 다시 요청하지 않습니다.
  /// (REST-06 → REST-05로 돌아갔다가 그대로 Next를 누르는 경우)
  /// 다시 분석해도 같은 질문 id에 대한 답변은 유지합니다.
  ///
  /// 분석 중에 뒤로 갔다가 다시 분석하면 요청이 겹칠 수 있습니다. 이때는 가장 최근에 시작한
  /// 요청의 응답만 반영하고, 그 전 요청의 응답은 (늦게 도착해도) 버립니다.
  ///
  /// 실패하면 상태를 바꾸지 않고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> analyze() async {
    final scanId = state.scanId;
    if (scanId == null) {
      throw StateError('analyze()는 recognize()가 성공한 뒤에 호출해야 합니다.');
    }

    final items = [
      for (final item in state.items)
        AnalyzeItem(tempId: item.id, rawName: item.nameForAnalysis),
    ];
    final selectedTempIds = [for (final item in state.selectedItems) item.id];
    final requestKey = _AnalyzeRequestKey(
      scanId: scanId,
      items: [for (final item in items) (item.tempId, item.rawName)],
      selectedTempIds: selectedTempIds,
    );
    if (state.menus.isNotEmpty && requestKey == _analyzedKey) return;

    final seq = ++_analyzeSeq;
    final response = await ref
        .read(scanRepositoryProvider)
        .analyze(
          scanId: scanId,
          items: items,
          selectedTempIds: selectedTempIds,
        );
    // 기다리는 동안 새 스캔을 시작했거나 더 최근 분석 요청이 있으면 이 응답은 버립니다.
    if (!ref.mounted || state.scanId != scanId || seq != _analyzeSeq) return;

    _analyzedKey = requestKey;
    final questions = response.questions.map(StaffQuestion.fromResponse);
    final questionIds = questions.map((question) => question.id).toSet();
    state = state.copyWith(
      menus: response.menus,
      questions: questions.toList(),
      answers: Map.fromEntries(
        state.answers.entries.where((e) => questionIds.contains(e.key)),
      ),
    );
  }

  /// REST-06에서 직원의 답변을 서버(POST /api/scans/{scan_id}/answers)에 기록합니다.
  ///
  /// 같은 질문에 다시 답하면 서버도 마지막 답으로 바꿉니다.
  /// 식당을 고른 스캔이면 이 답변은 같은 식당·메뉴를 보는 다른 사용자에게도 집계됩니다.
  ///
  /// 실패하면 상태를 바꾸지 않고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> answer(int questionId, StaffAnswer answer) async {
    final scanId = state.scanId;
    if (scanId == null) {
      throw StateError('answer()는 recognize()가 성공한 뒤에 호출해야 합니다.');
    }

    await ref
        .read(scanRepositoryProvider)
        .answer(
          scanId: scanId,
          questionId: questionId,
          answer: answer.apiValue,
        );
    if (!ref.mounted || state.scanId != scanId) return;

    state = state.copyWith(answers: {...state.answers, questionId: answer});
  }

  /// 직원 응답을 반영한 최종 판정(GET /api/scans/{scan_id}/result)으로 [ScanFlowState.menus]를 바꿉니다.
  ///
  /// 모든 질문에 답한 뒤(질문이 없으면 분석 직후) REST-07로 가기 전에 호출합니다.
  /// 확인하지 않은 차단 성분이 남아 있으면 safe가 나오지 않고, '모르겠어요'는 not_sure가 됩니다.
  ///
  /// 실패하면 상태를 바꾸지 않고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> loadResult() async {
    final scanId = state.scanId;
    if (scanId == null) {
      throw StateError('loadResult()는 analyze()가 성공한 뒤에 호출해야 합니다.');
    }

    final result = await ref.read(scanRepositoryProvider).result(scanId);
    if (!ref.mounted || state.scanId != scanId) return;

    state = state.copyWith(menus: result.menus);
  }

  /// REST-07 결과를 서버(POST /api/my-checks)에 저장합니다.
  ///
  /// 분석한 메뉴마다 확인 결과가 한 건씩 저장되어 홈 Recent Checks와 Saved Menus에 나타납니다.
  /// 이미 저장한 결과를 다시 저장하면(REST-08 → REST-07로 돌아온 경우) 다시 요청하지 않습니다.
  /// (서버도 같은 스캔을 다시 저장하면 그대로 둡니다)
  ///
  /// 실패하면 상태를 바꾸지 않고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> save() async {
    if (state.savedAt != null) return;
    final scanId = state.scanId;
    if (scanId == null) {
      throw StateError('save()는 loadResult()가 성공한 뒤에 호출해야 합니다.');
    }

    await ref.read(myChecksRepositoryProvider).save(scanId);
    if (!ref.mounted) return;
    // 홈 Recent Checks와 Saved Menus가 새로 저장한 메뉴를 보여주도록 다시 불러옵니다.
    ref.invalidate(myChecksProvider);
    if (state.scanId != scanId) return;
    state = state.copyWith(savedAt: DateTime.now());
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

/// 분석 요청 하나를 구분하는 값입니다. 필드를 하나하나 비교합니다.
/// (문자열로 이어 붙여 비교하면 메뉴 이름에 쉼표·콜론이 있을 때 서로 다른 요청이 같다고 판단될 수 있습니다)
class _AnalyzeRequestKey {
  const _AnalyzeRequestKey({
    required this.scanId,
    required this.items,
    required this.selectedTempIds,
  });

  final int scanId;

  /// (temp_id, raw_name) 목록입니다.
  final List<(String, String)> items;
  final List<String> selectedTempIds;

  @override
  bool operator ==(Object other) =>
      other is _AnalyzeRequestKey &&
      other.scanId == scanId &&
      listEquals(other.items, items) &&
      listEquals(other.selectedTempIds, selectedTempIds);

  @override
  int get hashCode => Object.hash(
    scanId,
    Object.hashAll(items),
    Object.hashAll(selectedTempIds),
  );
}
