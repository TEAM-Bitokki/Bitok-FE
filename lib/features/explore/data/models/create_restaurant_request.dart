import 'package:json_annotation/json_annotation.dart';

part 'create_restaurant_request.g.dart';
@JsonSerializable(createFactory: false)
class CreateRestaurantRequest {
  const CreateRestaurantRequest({
    required this.kakaoPlaceId,
    required this.name,
    required this.lat,
    required this.lng,
  });

  final String kakaoPlaceId;
  final String name;
  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => _$CreateRestaurantRequestToJson(this);
}