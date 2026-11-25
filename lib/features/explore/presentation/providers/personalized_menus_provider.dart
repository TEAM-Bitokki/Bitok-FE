import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/explore_repository.dart';
import '../models/menu_verdict.dart';
import '../screens/personalized_menu_list_screen.dart';

final personalizedMenusProvider = FutureProvider.autoDispose
    .family<List<PersonalizedMenu>, int>((ref, restaurantId) async {
  final items = await ref
      .watch(exploreRepositoryProvider)
      .forYou(restaurantId);
  return [
    for (final item in items)
      PersonalizedMenu(
        dishId: item.dishId,
        koreanName: item.nameKo,
        englishName: item.nameEn ?? item.nameKo,
        status: menuStatusOfVerdict(item.verdict),
      ),
  ];
});