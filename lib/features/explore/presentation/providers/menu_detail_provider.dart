import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_status_chip.dart';
import '../../data/models/menu_detail_response.dart';
import '../../data/repositories/explore_repository.dart';
import '../models/menu_verdict.dart';
import '../screens/menu_detail_screen.dart';

typedef MenuDetailKey = ({int restaurantId, int dishId});

/// 식당 메뉴 상세(GET /api/restaurants/{id}/menus/{dish_id})입니다.
/// 같은 식당·메뉴를 본 사용자들의 응답을 모은 판정입니다.
final menuDetailProvider = FutureProvider.autoDispose
    .family<MenuDetail, MenuDetailKey>((ref, key) async {
  final response = await ref
      .watch(exploreRepositoryProvider)
      .menuDetail(restaurantId: key.restaurantId, dishId: key.dishId);
  return menuDetailOfResponse(response);
});

/// 메뉴 상세 응답을 화면 모델로 바꿉니다.
/// 식당 메뉴 상세와 내 기록의 메뉴 상세(GET /api/analyses/{id})가 함께 씁니다.
MenuDetail menuDetailOfResponse(MenuDetailResponse response) {
  List<String> ingredientsOf(BitokMenuStatus status) => {
    for (final match in response.matches)
      if (menuStatusOfVerdict(match.verdict) == status)
        match.ingredientEn ?? match.ingredient,
  }.toList();

  return MenuDetail(
    englishName: response.dish.nameEn ?? response.dish.nameKo,
    avoidIngredients: ingredientsOf(BitokMenuStatus.avoid),
    notSureIngredients: ingredientsOf(BitokMenuStatus.notSure),
    commonIngredients: [
      for (final group in response.commonIngredients)
        CommonIngredient(category: group.tagEn, items: group.ingredients),
    ],
  );
}
