import '../../data/models/scan_menu_item.dart';

/// 메뉴 스캔 플로우(REST-02 ~ REST-08) 동안 화면끼리 공유하는 상태입니다.
class ScanFlowState {
  const ScanFlowState({this.imagePath, this.items = const []});

  /// 스캔한 메뉴판 이미지 경로입니다.
  final String? imagePath;

  /// 인식한 메뉴 목록입니다. REST-04에서 수정/추가/삭제할 수 있습니다.
  final List<ScanMenuItem> items;

  ScanFlowState copyWith({String? imagePath, List<ScanMenuItem>? items}) {
    return ScanFlowState(
      imagePath: imagePath ?? this.imagePath,
      items: items ?? this.items,
    );
  }
}
