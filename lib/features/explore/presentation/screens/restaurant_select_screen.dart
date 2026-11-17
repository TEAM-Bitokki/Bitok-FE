import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../models/map_restaurant.dart';
import '../widgets/restaurant_map_search_view.dart';
import '../widgets/restaurant_preview_card.dart';

/// 식당을 검색하거나 지도에서 골라 Select 로 확정합니다. (지도 API 연동 전)
class RestaurantSelectScreen extends StatelessWidget {
  const RestaurantSelectScreen({
    super.key,
    required this.restaurants,
    this.onBack,
    this.onSelect,
  });

  final List<MapRestaurant> restaurants;
  final VoidCallback? onBack;
  final ValueChanged<MapRestaurant>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Restaurant Select',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: RestaurantMapSearchView(
        restaurants: restaurants,
        previewBuilder: (context, restaurant) => RestaurantPreviewCard(
          restaurant: restaurant,
          footer: BitokButton(
            label: 'Select',
            onPressed: () => onSelect?.call(restaurant),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Restaurant Select', size: Size(390, 844))
Widget restaurantSelectPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: RestaurantSelectScreen(
    restaurants: mapRestaurantSamples,
  ),
);
