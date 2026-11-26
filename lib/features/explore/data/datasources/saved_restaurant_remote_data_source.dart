import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/list_response.dart';
import '../models/restaurant_brief.dart';
import '../models/save_restaurant_request.dart';

// 저장한 식당(북마크) API입니다. 마이페이지 Saved Restaurants와 지도·식당 상세의 북마크가 씁니다.
class SavedRestaurantRemoteDataSource {
  SavedRestaurantRemoteDataSource(this._api);

  final ApiClient _api;

  /// 저장한 식당을 최신순으로 가져옵니다. 페이지 없이 전체를 돌려줍니다.
  Future<ListResponse<RestaurantBrief>> list() async => ApiClient.decode(
    await _api.get('/api/saved-restaurants'),
    (json) => ListResponse.fromJson(json, RestaurantBrief.fromJson),
  );

  /// 식당을 저장합니다. 이미 저장된 식당이어도 성공(201)으로 처리됩니다.
  /// 없는 식당이면 ApiException(ErrorCode.notFound)을 던집니다.
  Future<void> save(SaveRestaurantRequest request) async {
    await _api.post('/api/saved-restaurants', data: request.toJson());
  }

  /// 저장을 해제합니다. 성공하면 204(body 없음)입니다.
  /// 저장되지 않은 식당이면 ApiException(ErrorCode.notFound)을 던집니다.
  Future<void> delete(int restaurantId) async {
    await _api.delete('/api/saved-restaurants/$restaurantId');
  }
}

final savedRestaurantRemoteDataSourceProvider =
    Provider<SavedRestaurantRemoteDataSource>(
      (ref) => SavedRestaurantRemoteDataSource(ref.watch(apiClientProvider)),
    );
