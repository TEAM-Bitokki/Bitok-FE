import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/list_response.dart';
import '../models/my_check_item.dart';
import '../models/save_my_check_request.dart';

// 저장한 메뉴(My Checks) API입니다.
class MyChecksRemoteDataSource {
  MyChecksRemoteDataSource(this._api);

  final ApiClient _api;

  /// 저장한 메뉴를 최신순으로 가져옵니다. 첫 페이지는 [cursor]를 넘기지 않습니다.
  /// [limit]은 1~50이고, 넘기지 않으면 서버 기본값(20)을 씁니다.
  Future<PagedResponse<MyCheckItem>> list({String? cursor, int? limit}) async =>
      ApiClient.decode(
        await _api.get(
          '/api/my-checks',
          query: {'cursor': ?cursor, 'limit': ?limit},
        ),
        (json) => PagedResponse.fromJson(json, MyCheckItem.fromJson),
      );

  /// 스캔 결과를 저장합니다. 성공하면 204(body 없음)입니다.
  /// 없는 스캔이거나 아직 분석 전이면 ApiException(ErrorCode.notFound)을 던집니다.
  Future<void> save(SaveMyCheckRequest request) async {
    await _api.post('/api/my-checks', data: request.toJson());
  }
}

final myChecksRemoteDataSourceProvider = Provider<MyChecksRemoteDataSource>(
  (ref) => MyChecksRemoteDataSource(ref.watch(apiClientProvider)),
);
