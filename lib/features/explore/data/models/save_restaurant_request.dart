import 'package:json_annotation/json_annotation.dart';

part 'save_restaurant_request.g.dart';

/// POST /api/saved-restaurants 요청 body.
/// 서버에 등록된 식당(restaurant_id가 있는 식당)만 저장할 수 있습니다.
@JsonSerializable(createFactory: false)
class SaveRestaurantRequest {
  const SaveRestaurantRequest({required this.restaurantId});

  final int restaurantId;

  Map<String, dynamic> toJson() => _$SaveRestaurantRequestToJson(this);
}
