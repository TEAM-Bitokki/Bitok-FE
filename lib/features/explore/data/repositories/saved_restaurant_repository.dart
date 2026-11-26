import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_code.dart';
import '../datasources/saved_restaurant_remote_data_source.dart';
import '../models/restaurant_brief.dart';
import '../models/save_restaurant_request.dart';

class SavedRestaurantRepository {
  const SavedRestaurantRepository(this._remote);

  final SavedRestaurantRemoteDataSource _remote;

  Future<List<RestaurantBrief>> list() async => (await _remote.list()).items;

  Future<void> save(int restaurantId) =>
      _remote.save(SaveRestaurantRequest(restaurantId: restaurantId));

  /// 저장을 해제합니다. 이미 해제된 식당(404)이면 원하는 상태이므로 성공으로 봅니다.
  Future<void> unsave(int restaurantId) async {
    try {
      await _remote.delete(restaurantId);
    } on ApiException catch (e) {
      if (e.code != ErrorCode.notFound) rethrow;
    }
  }
}

final savedRestaurantRepositoryProvider = Provider<SavedRestaurantRepository>(
  (ref) => SavedRestaurantRepository(
    ref.watch(savedRestaurantRemoteDataSourceProvider),
  ),
);
