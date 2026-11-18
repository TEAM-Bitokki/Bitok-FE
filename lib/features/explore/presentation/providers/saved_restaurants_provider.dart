import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 저장한 식당 목록(마이페이지)과 북마크가 이 값을 함께 씁니다. 저장한 순서를 유지합니다.
class SavedRestaurantIdsNotifier extends Notifier<Set<String>> {
  // TODO: 저장 API 연결 시 서버 값으로 교체합니다. 'myeongdong-kyoja'는 화면 확인용 mock입니다.
  @override
  Set<String> build() => {'myeongdong-kyoja'};

  void toggle(String id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
  }
}

final savedRestaurantIdsProvider =
    NotifierProvider<SavedRestaurantIdsNotifier, Set<String>>(
      SavedRestaurantIdsNotifier.new,
    );
