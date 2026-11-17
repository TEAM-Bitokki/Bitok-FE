import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/router/main_shell.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_icons.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../models/map_restaurant.dart';
import '../widgets/restaurant_map_search_view.dart';
import '../widgets/restaurant_preview_card.dart';

/// 지도 API 연동 전입니다.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({
    super.key,
    required this.restaurants,
    this.savedIds = const {},
    this.onProfileTap,
    this.onToggleSaved,
    this.onMenuResultsTap,
  });

  final List<MapRestaurant> restaurants;

  /// 저장(북마크)된 식당 id
  final Set<String> savedIds;

  final VoidCallback? onProfileTap;

  /// 북마크를 누르면 호출됩니다.
  final ValueChanged<MapRestaurant>? onToggleSaved;

  /// "N menu results" 를 누르면 호출됩니다. (식당 상세로 이동)
  final ValueChanged<MapRestaurant>? onMenuResultsTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      appBar: BitokHeader.explore(title: 'Explore', onProfile: onProfileTap),
      body: RestaurantMapSearchView(
        restaurants: restaurants,
        previewBuilder: (context, restaurant) => RestaurantPreviewCard(
          restaurant: restaurant,
          footerGap: 15,
          bottomPadding: MainShell.contentBottomInset + 16,
          trailing: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onToggleSaved?.call(restaurant),
            child: SvgPicture.asset(
              savedIds.contains(restaurant.id)
                  ? BitokIcons.saveOn24
                  : BitokIcons.saveOff24,
              width: 24,
              height: 24,
            ),
          ),
          footer: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onMenuResultsTap?.call(restaurant),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${restaurant.menuCount} menu results',
                  style: BitokTextStyles.buttonText2.copyWith(
                    color: BitokColors.primary,
                  ),
                ),
                SvgPicture.asset(BitokIcons.leftArrow20, width: 20, height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Explore', size: Size(390, 844))
Widget exploreScreenPreview() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: ExploreScreen(restaurants: mapRestaurantSamples),
);