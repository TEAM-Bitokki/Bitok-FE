import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/account_provider.dart';
import '../../data/models/restaurant_brief.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../data/repositories/saved_restaurant_repository.dart';

/// 저장한 식당 목록(GET /api/saved-restaurants)입니다. 최근에 저장한 것이 앞에 옵니다.
///
/// 마이페이지 Saved Restaurants와 지도·식당 상세의 북마크가 함께 씁니다.
/// 로그인한 계정(userId)이 바뀌면 다시 불러옵니다.
class SavedRestaurantsNotifier extends AsyncNotifier<List<RestaurantBrief>> {
  /// 저장/해제 요청 중인 식당(kakao_place_id)입니다. 연타로 요청이 겹치지 않게 막습니다.
  final Set<String> _pending = {};

  @override
  Future<List<RestaurantBrief>> build() async {
    final userId = ref.watch(accountProvider.select((a) => a?.userId));
    if (userId == null) return const [];
    return ref.read(savedRestaurantRepositoryProvider).list();
  }

  /// 저장되어 있으면 해제하고, 아니면 저장합니다.
  ///
  /// 화면이 바로 바뀌도록 먼저 목록을 고친 뒤 서버에 보냅니다.
  /// 서버에 아직 등록되지 않은 식당(restaurantId가 null)은 먼저 등록(POST /api/restaurants)합니다.
  /// 실패하면 목록을 되돌리고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> toggle(RestaurantBrief restaurant) async {
    final placeId = restaurant.kakaoPlaceId;
    if (!_pending.add(placeId)) return;
    try {
      final before = await future;
      final saved = before.any((r) => r.kakaoPlaceId == placeId);
      if (saved) {
        final target = before.firstWhere((r) => r.kakaoPlaceId == placeId);
        state = AsyncData([
          for (final r in before)
            if (r.kakaoPlaceId != placeId) r,
        ]);
        await _send(before, () async {
          final restaurantId = target.restaurantId ?? restaurant.restaurantId;
          if (restaurantId != null) {
            await ref
                .read(savedRestaurantRepositoryProvider)
                .unsave(restaurantId);
          }
        });
      } else {
        state = AsyncData([restaurant, ...before]);
        await _send(before, () async {
          final registered = restaurant.restaurantId != null
              ? restaurant
              : await ref
                    .read(restaurantRepositoryProvider)
                    .register(restaurant);
          await ref
              .read(savedRestaurantRepositoryProvider)
              .save(registered.restaurantId!);
          // 등록으로 받은 restaurantId가 목록에 남도록 바꿔 둡니다.
          if (ref.mounted && !identical(registered, restaurant)) {
            state = AsyncData([
              for (final r in state.value ?? const <RestaurantBrief>[])
                r.kakaoPlaceId == placeId ? registered : r,
            ]);
          }
        });
      }
    } finally {
      _pending.remove(placeId);
    }
  }

  /// [request]가 실패하면 목록을 [before]로 되돌리고 예외를 다시 던집니다.
  Future<void> _send(
    List<RestaurantBrief> before,
    Future<void> Function() request,
  ) async {
    final userId = ref.read(accountProvider)?.userId;
    try {
      await request();
    } catch (_) {
      // 기다리는 동안 계정이 바뀌었으면(탈퇴 등) 이전 계정의 목록으로 되돌리지 않습니다.
      if (ref.mounted && ref.read(accountProvider)?.userId == userId) {
        state = AsyncData(before);
      }
      rethrow;
    }
  }
}

final savedRestaurantsProvider =
    AsyncNotifierProvider<SavedRestaurantsNotifier, List<RestaurantBrief>>(
      SavedRestaurantsNotifier.new,
    );

/// 저장한 식당의 kakao_place_id입니다. 북마크 아이콘 표시에 씁니다.
/// 불러오는 중이거나 실패하면 비어 있습니다.
final savedRestaurantIdsProvider = Provider<Set<String>>(
  (ref) => {
    for (final restaurant
        in ref.watch(savedRestaurantsProvider).value ?? const [])
      restaurant.kakaoPlaceId,
  },
);
