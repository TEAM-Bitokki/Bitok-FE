import '../../data/models/scan_menu_item.dart';

/// 메뉴 스캔 플로우(REST-02 ~ REST-08) 동안 화면끼리 공유하는 상태입니다.
class ScanFlowState {
  const ScanFlowState({
    this.imagePath,
    this.items = const [],
    this.selectedIds = const {},
  });

  /// 스캔한 메뉴판 이미지 경로입니다.
  final String? imagePath;

  /// 인식한 메뉴 목록입니다. REST-04에서 수정/추가/삭제할 수 있습니다.
  final List<ScanMenuItem> items;

  /// REST-05에서 분석하려고 고른 메뉴의 id입니다.
  final Set<String> selectedIds;

  /// [selectedIds]에 해당하는 메뉴를 목록 순서대로 반환합니다.
  List<ScanMenuItem> get selectedItems =>
      items.where((item) => selectedIds.contains(item.id)).toList();

  /// 예: '3 menu items recognized'
  String get recognizedLabel => items.length == 1
      ? '1 menu item recognized'
      : '${items.length} menu items recognized';

  ScanFlowState copyWith({
    String? imagePath,
    List<ScanMenuItem>? items,
    Set<String>? selectedIds,
  }) {
    return ScanFlowState(
      imagePath: imagePath ?? this.imagePath,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}
