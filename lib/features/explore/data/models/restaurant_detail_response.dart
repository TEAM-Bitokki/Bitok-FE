import 'package:json_annotation/json_annotation.dart';

import 'restaurant_brief.dart';

part 'restaurant_detail_response.g.dart';

@JsonSerializable(createToJson: false)
class CheckedMenuItem {
  const CheckedMenuItem({
    required this.dishId,
    required this.nameKo,
    this.nameEn,
  });

  factory CheckedMenuItem.fromJson(Map<String, dynamic> json) =>
      _$CheckedMenuItemFromJson(json);

  final int dishId;
  final String nameKo;
  final String? nameEn;
}

@JsonSerializable(createToJson: false)
class CheckedMenusPage {
  const CheckedMenusPage({this.nextCursor, this.hasMore = false});

  factory CheckedMenusPage.fromJson(Map<String, dynamic> json) =>
      _$CheckedMenusPageFromJson(json);

  final String? nextCursor;
  final bool hasMore;
}

@JsonSerializable(createToJson: false)
class RestaurantDetailResponse {
  const RestaurantDetailResponse({
    required this.restaurant,
    required this.checkedMenus,
    required this.page,
  });

  factory RestaurantDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$RestaurantDetailResponseFromJson(json);

  final RestaurantBrief restaurant;
  final List<CheckedMenuItem> checkedMenus;
  final CheckedMenusPage page;
}