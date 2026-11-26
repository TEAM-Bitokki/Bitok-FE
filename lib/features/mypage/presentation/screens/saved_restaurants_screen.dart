import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../core/design_system/bitok_colors.dart';

class SavedRestaurant {
  const SavedRestaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
  });

  /// 식당 상세('/restaurant/:id')로 이동할 때 쓰는 서버 restaurant_id입니다.
  final String id;
  final String name;
  final String category;
  final String address;
}


class SavedRestaurantsScreen extends StatelessWidget {
  const SavedRestaurantsScreen({
    super.key,
    required this.restaurants,
    this.onBack,
    this.onRestaurantTap,
  });

  final List<SavedRestaurant> restaurants;
  final VoidCallback? onBack;
  final ValueChanged<SavedRestaurant>? onRestaurantTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.sub(
        title: 'Saved Restaurants',
        onBack: onBack ?? () => Navigator.maybePop(context),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          itemCount: restaurants.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return BitokSavedRestaurantCard(
              name: restaurant.name,
              category: restaurant.category,
              address: restaurant.address,
              onTap: () => onRestaurantTap?.call(restaurant),
            );
          },
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Saved Restaurants', size: Size(390, 844))
Widget savedRestaurantsPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: SavedRestaurantsScreen(
    restaurants: [
      SavedRestaurant(
        id: 'myeongdong-kyoja',
        name: 'Myeongdong Kyoja',
        category: 'Korean Restaurant',
        address: '29 Myeongdong 10-gil, Jung-gu',
      ),
      SavedRestaurant(
        id: 'myeongdong-kyoja',
        name: 'Myeongdong Kyoja',
        category: 'Korean Restaurant',
        address: '29 Myeongdong 10-gil, Jung-gu',
      ),
      SavedRestaurant(
        id: 'myeongdong-kyoja',
        name: 'Myeongdong Kyoja',
        category: 'Korean Restaurant',
        address: '29 Myeongdong 10-gil, Jung-gu',
      ),
    ],
  ),
);
