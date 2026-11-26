import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/models/list_response.dart';
import '../datasources/my_checks_remote_data_source.dart';
import '../models/my_check_item.dart';
import '../models/save_my_check_request.dart';

class MyChecksRepository {
  const MyChecksRepository(this._remote);

  final MyChecksRemoteDataSource _remote;

  /// 다음 페이지는 이전 응답의 page.nextCursor를 [cursor]로 넘깁니다(hasMore가 true일 때만).
  Future<PagedResponse<MyCheckItem>> list({String? cursor, int? limit}) =>
      _remote.list(cursor: cursor, limit: limit);

  Future<void> save(int scanId) =>
      _remote.save(SaveMyCheckRequest(scanId: scanId));
}

final myChecksRepositoryProvider = Provider<MyChecksRepository>(
  (ref) => MyChecksRepository(ref.watch(myChecksRemoteDataSourceProvider)),
);
