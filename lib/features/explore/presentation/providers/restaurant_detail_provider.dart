import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/location_service.dart';
import '../../data/models/restaurant_detail_response.dart';
import '../../data/repositories/explore_repository.dart';

final restaurantDetailProvider = FutureProvider.autoDispose
    .family<RestaurantDetailResponse, int>((ref, restaurantId) {
  final location = LocationService.cached;
  return ref
      .watch(exploreRepositoryProvider)
      .detail(restaurantId, lat: location?.lat, lng: location?.lng);
});