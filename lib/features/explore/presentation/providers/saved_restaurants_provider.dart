import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TODO: 저장 API 연결 시 서버 값으로 교체합니다.
class SavedRestaurantIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
  }
}

final savedRestaurantIdsProvider =
NotifierProvider<SavedRestaurantIdsNotifier, Set<String>>(
  SavedRestaurantIdsNotifier.new,
);