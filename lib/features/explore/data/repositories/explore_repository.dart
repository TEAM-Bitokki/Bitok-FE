import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/explore_remote_data_source.dart';
import '../models/menu_detail_response.dart';
import '../models/personalized_menu_item.dart';
import '../models/restaurant_brief.dart';
import '../models/restaurant_detail_response.dart';

class ExploreRepository {
  const ExploreRepository(this._remote);

  final ExploreRemoteDataSource _remote;

  Future<List<RestaurantBrief>> checked({
    required double lat,
    required double lng,
    int? radiusM,
    int? limit,
  }) async => (await _remote.checked(
    lat: lat,
    lng: lng,
    radiusM: radiusM,
    limit: limit,
  )).items;

  Future<RestaurantDetailResponse> detail(
      int restaurantId, {
        String? cursor,
        int? limit,
        double? lat,
        double? lng,
      }) => _remote.detail(
    restaurantId,
    cursor: cursor,
    limit: limit,
    lat: lat,
    lng: lng,
  );

  Future<List<PersonalizedMenuItem>> forYou(int restaurantId) async =>
      (await _remote.forYou(restaurantId)).items;

  Future<MenuDetailResponse> menuDetail({
    required int restaurantId,
    required int dishId,
  }) => _remote.menuDetail(restaurantId: restaurantId, dishId: dishId);
}

final exploreRepositoryProvider = Provider<ExploreRepository>(
      (ref) => ExploreRepository(ref.watch(exploreRemoteDataSourceProvider)),
);