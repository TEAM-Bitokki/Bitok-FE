import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/list_response.dart';
import '../models/menu_detail_response.dart';
import '../models/personalized_menu_item.dart';
import '../models/restaurant_brief.dart';
import '../models/restaurant_detail_response.dart';

class ExploreRemoteDataSource {
  ExploreRemoteDataSource(this._api);

  final ApiClient _api;

  Future<ListResponse<RestaurantBrief>> checked({
    required double lat,
    required double lng,
    int? radiusM,
    int? limit,
  }) async => ApiClient.decode(
    await _api.get(
      '/api/restaurants/checked',
      query: {
        'lat': lat,
        'lng': lng,
        if (radiusM != null) 'radius_m': radiusM,
        if (limit != null) 'limit': limit,
      },
    ),
        (json) => ListResponse.fromJson(json, RestaurantBrief.fromJson),
  );

  Future<RestaurantDetailResponse> detail(
      int restaurantId, {
        String? cursor,
        int? limit,
        double? lat,
        double? lng,
      }) async => ApiClient.decode(
    await _api.get(
      '/api/restaurants/$restaurantId',
      query: {
        if (cursor != null) 'cursor': cursor,
        if (limit != null) 'limit': limit,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      },
    ),
    RestaurantDetailResponse.fromJson,
  );

  Future<ListResponse<PersonalizedMenuItem>> forYou(int restaurantId) async =>
      ApiClient.decode(
        await _api.get('/api/restaurants/$restaurantId/menus/for-you'),
            (json) => ListResponse.fromJson(json, PersonalizedMenuItem.fromJson),
      );

  Future<MenuDetailResponse> menuDetail({
    required int restaurantId,
    required int dishId,
  }) async => ApiClient.decode(
    await _api.get('/api/restaurants/$restaurantId/menus/$dishId'),
    MenuDetailResponse.fromJson,
  );
}

final exploreRemoteDataSourceProvider = Provider<ExploreRemoteDataSource>(
      (ref) => ExploreRemoteDataSource(ref.watch(apiClientProvider)),
);