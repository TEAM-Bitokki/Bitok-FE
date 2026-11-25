import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/location_service.dart';
import '../../data/repositories/explore_repository.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../models/map_restaurant.dart';

typedef MapCenter = ({double lat, double lng});
typedef NearbyQuery = ({MapCenter? center, bool checkedOnly});

const MapCenter _fallbackLocation = (lat: 37.5636, lng: 126.9850);

final userLocationProvider = FutureProvider.autoDispose<MapCenter?>((
    ref,
    ) async {
  final cached = LocationService.cached;
  if (cached != null) return cached;
  try {
    return await LocationService.current() ?? LocationService.cached;
  } catch (_) {
    return LocationService.cached;
  }
});

final nearbyRestaurantsProvider = FutureProvider.autoDispose
    .family<List<MapRestaurant>, NearbyQuery>((ref, query) async {
  final target =
      query.center ??
          ref.watch(userLocationProvider).value ??
          _fallbackLocation;
  if (query.checkedOnly) {
    final briefs = await ref
        .watch(exploreRepositoryProvider)
        .checked(lat: target.lat, lng: target.lng);
    return [for (final brief in briefs) MapRestaurant.fromBrief(brief)];
  }
  final briefs = await ref
      .watch(restaurantRepositoryProvider)
      .nearby(lat: target.lat, lng: target.lng);
  return [for (final brief in briefs) MapRestaurant.fromBrief(brief)];
});