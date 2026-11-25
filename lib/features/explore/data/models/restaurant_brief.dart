import 'package:json_annotation/json_annotation.dart';

part 'restaurant_brief.g.dart';

@JsonSerializable(createToJson: false)
class RestaurantBrief {
  const RestaurantBrief({
    required this.kakaoPlaceId,
    required this.name,
    required this.lat,
    required this.lng,
    this.restaurantId,
    this.category,
    this.address,
    this.distanceM,
    this.checkedMenuCount = 0,
    this.isSaved = false,
  });

  final int? restaurantId;

  final String kakaoPlaceId;

  final String name;
  final String? category;
  final String? address;
  final double lat;
  final double lng;

  final double? distanceM;
  final int checkedMenuCount;

  final bool isSaved;

  factory RestaurantBrief.fromJson(Map<String, dynamic> json) =>
      _$RestaurantBriefFromJson(json);
}