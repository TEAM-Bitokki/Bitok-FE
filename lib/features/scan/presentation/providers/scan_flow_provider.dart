import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/scan_menu_item.dart';
import 'scan_flow_state.dart';

/// 메뉴 스캔 플로우의 상태(이미지, 인식한 메뉴 목록)를 관리합니다.
class ScanFlowNotifier extends Notifier<ScanFlowState> {
  int _nextId = 0;

  @override
  ScanFlowState build() => const ScanFlowState();

  /// 메뉴판 이미지에서 메뉴를 인식합니다. 이전 스캔 결과는 지웁니다.
  Future<void> recognize(String imagePath) async {
    // TODO: OCR API를 연결하면 응답으로 메뉴 목록을 채웁니다.
    // 연동 전까지는 화면 확인을 위해 임시 데이터를 사용합니다.
    state = ScanFlowState(
      imagePath: imagePath,
      items: [
        _newItem(koreanName: '김치찌개', englishName: 'Kimchi Jjigae'),
        _newItem(koreanName: '비빔밥', englishName: 'Bibimbap'),
        _newItem(koreanName: '불고기', englishName: 'Bulgogi'),
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

  /// 메뉴를 목록에서 지웁니다.
  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != id).toList(),
    );
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

  ScanMenuItem _newItem({
    required String koreanName,
    required String englishName,
  }) {
    return ScanMenuItem(
      id: '${_nextId++}',
      koreanName: koreanName,
      englishName: englishName,
    );
  }
}

final scanFlowProvider = NotifierProvider<ScanFlowNotifier, ScanFlowState>(
  ScanFlowNotifier.new,
);
