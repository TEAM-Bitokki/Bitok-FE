import '../../data/models/restaurant_brief.dart';

class MapRestaurant {
  const MapRestaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.checkedMenuCount,
    required this.lat,
    required this.lng,
    this.restaurantId,
  });

  factory MapRestaurant.fromBrief(RestaurantBrief brief) => MapRestaurant(
    id: brief.kakaoPlaceId,
    restaurantId: brief.restaurantId,
    name: brief.name,
    category: brief.category ?? '',
    address: brief.address ?? '',
    checkedMenuCount: brief.checkedMenuCount,
    lat: brief.lat,
    lng: brief.lng,
  );

  /// kakao_place_id입니다.
  final String id;

  /// 서버에 등록되기 전에는 null입니다.
  final int? restaurantId;

  final String name;
  final String category;
  final String address;

  final int checkedMenuCount;

  final double lat;
  final double lng;

  RestaurantBrief toBrief() => RestaurantBrief(
    restaurantId: restaurantId,
    kakaoPlaceId: id,
    name: name,
    category: category.isEmpty ? null : category,
    address: address.isEmpty ? null : address,
    lat: lat,
    lng: lng,
    checkedMenuCount: checkedMenuCount,
  );
}