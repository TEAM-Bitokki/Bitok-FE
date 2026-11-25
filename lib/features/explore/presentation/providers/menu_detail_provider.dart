import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_status_chip.dart';
import '../../data/repositories/explore_repository.dart';
import '../models/menu_verdict.dart';
import '../screens/menu_detail_screen.dart';

typedef MenuDetailKey = ({int restaurantId, int dishId});

final menuDetailProvider = FutureProvider.autoDispose
    .family<MenuDetail, MenuDetailKey>((ref, key) async {
  final response = await ref
      .watch(exploreRepositoryProvider)
      .menuDetail(restaurantId: key.restaurantId, dishId: key.dishId);

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
});