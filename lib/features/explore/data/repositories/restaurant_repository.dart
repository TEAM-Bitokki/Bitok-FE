import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/restaurant_remote_data_source.dart';
import '../models/create_restaurant_request.dart';
import '../models/restaurant_brief.dart';

class RestaurantRepository {
  RestaurantRepository(this._remote);

  final RestaurantRemoteDataSource _remote;

  Future<List<RestaurantBrief>> nearby({
    required double lat,
    required double lng,
    int? radiusM,
    int? limit,
  }) async => (await _remote.nearby(
    lat: lat,
    lng: lng,
    radiusM: radiusM,
    limit: limit,
  )).items;
  Future<List<RestaurantBrief>> search(
      String query, {
        double? lat,
        double? lng,
        int? limit,
      }) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    return (await _remote.search(q: q, lat: lat, lng: lng, limit: limit)).items;
  }

  Future<RestaurantBrief> register(RestaurantBrief restaurant) =>
      _remote.register(
        CreateRestaurantRequest(
          kakaoPlaceId: restaurant.kakaoPlaceId,
          name: restaurant.name,
          lat: restaurant.lat,
          lng: restaurant.lng,
        ),
      );
}

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
      (ref) => RestaurantRepository(ref.watch(restaurantRemoteDataSourceProvider)),
);