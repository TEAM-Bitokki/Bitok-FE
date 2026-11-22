import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/ingredient_item.dart';
import '../models/profile_request.dart';
import '../models/profile_response.dart';

// 식이 프로필과 알레르기 성분 검색 API입니다.
// 온보딩과 마이페이지가 함께 쓰며, repository만 이 클래스를 호출합니다.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._api);

  final ApiClient _api;

  /// 프로필이 없으면 ApiException(ErrorCode.notFound)을 던집니다.
  Future<ProfileResponse> getProfile() async => ApiClient.decode(
    await _api.get('/api/profiles/me'),
    ProfileResponse.fromJson,
  );

  /// 프로필을 통째로 덮어쓰고, 저장된 프로필을 돌려줍니다.
  Future<ProfileResponse> putProfile(ProfileRequest request) async =>
      ApiClient.decode(
        await _api.put('/api/profiles/me', data: request.toJson()),
        ProfileResponse.fromJson,
      );

  /// 알레르기 성분을 한국어·영어·별칭으로 검색합니다.
  ///
  /// 빈 검색어면 전체 목록을 돌려주기로 백엔드와 합의했습니다.
  /// [limit]을 넘기지 않으면 서버 기본값(20)을 씁니다.
  Future<IngredientSearchResponse> searchIngredients({
    String query = '',
    int? limit,
  }) async => ApiClient.decode(
    await _api.get(
      '/api/ingredients/search',
      query: {'q': query.trim(), 'limit': ?limit},
    ),
    IngredientSearchResponse.fromJson,
  );
}

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  return ProfileRemoteDataSource(ref.watch(apiClientProvider));
});
