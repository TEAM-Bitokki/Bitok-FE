import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/list_response.dart';
import '../models/create_restaurant_request.dart';
import '../models/restaurant_brief.dart';

class RestaurantRemoteDataSource {
  RestaurantRemoteDataSource(this._api);

  final ApiClient _api;

  Future<ListResponse<RestaurantBrief>> nearby({
    required double lat,
    required double lng,
    int? radiusM,
    int? limit,
  }) async => ApiClient.decode(
    await _api.get(
      '/api/restaurants/nearby',
      query: {
        'lat': lat,
        'lng': lng,
        if (radiusM != null) 'radius_m': radiusM,
        if (limit != null) 'limit': limit,
      },
    ),
    (json) => ListResponse.fromJson(json, RestaurantBrief.fromJson),
  );

  Future<ListResponse<RestaurantBrief>> search({
    required String q,
    double? lat,
    double? lng,
    int? limit,
  }) async => ApiClient.decode(
    await _api.get(
      '/api/restaurants/search',
      query: {
        'q': q,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (limit != null) 'limit': limit,
      },
    ),
    (json) => ListResponse.fromJson(json, RestaurantBrief.fromJson),
  );

  Future<RestaurantBrief> register(CreateRestaurantRequest request) async =>
      ApiClient.decode(
        await _api.post('/api/restaurants', data: request.toJson()),
        RestaurantBrief.fromJson,
      );
}

final restaurantRemoteDataSourceProvider = Provider<RestaurantRemoteDataSource>(
  (ref) => RestaurantRemoteDataSource(ref.watch(apiClientProvider)),
);
