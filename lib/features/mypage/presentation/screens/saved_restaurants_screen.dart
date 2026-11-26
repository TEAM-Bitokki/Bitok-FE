import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../common/widgets/bitok_empty_state.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../common/widgets/bitok_load_more.dart';
import '../../../../common/widgets/bitok_menu_card.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

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
    this.isLoading = false,
    this.loadFailed = false,
    this.onRetry,
    this.onBack,
    this.onRestaurantTap,
  });

  final List<SavedRestaurant> restaurants;

  /// 목록을 처음 불러오는 중이면 true입니다. 목록 대신 로딩 표시를 보여줍니다.
  final bool isLoading;

  /// 목록을 불러오지 못했으면 true입니다. 빈 화면 대신 안내 문구와 [onRetry] 버튼을 보여줍니다.
  /// (저장한 식당이 없는 것과 불러오지 못한 것을 구분합니다)
  final bool loadFailed;
  final VoidCallback? onRetry;

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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: BitokColors.primary),
              )
            : restaurants.isEmpty
            // 홈 Recent checks의 빈 상태와 같은 위치(목록 시작점 아래)에 둡니다.
            ? Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 45, 24, 24),
                  child: loadFailed
                      ? BitokLoadMoreFooter(
                          loading: false,
                          failed: true,
                          onRetry: onRetry,
                        )
                      : BitokEmptyState(
                          message: AppLocalizations.of(
                            context,
                          ).savedRestaurantsEmpty,
                        ),
                ),
              )
            : ListView.separated(
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
