import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedRestaurantIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? restaurantId) => state = restaurantId;
}

final selectedRestaurantIdProvider =
NotifierProvider<SelectedRestaurantIdNotifier, int?>(
  SelectedRestaurantIdNotifier.new,
);