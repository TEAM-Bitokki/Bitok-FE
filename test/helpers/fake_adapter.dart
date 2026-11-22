import 'dart:convert';

import 'package:dio/dio.dart';

/// 실제 서버 대신 경로별로 정해둔 응답을 돌려주는 어댑터.
/// 키는 'METHOD /path' 형식이고, 값은 (상태 코드, body)입니다. body가 null이면 빈 응답입니다.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.routes);

  final Map<String, (int, Object?)> routes;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? _,
    Future<void>? _,
  ) async {
    requests.add(options);
    final (status, body) =
        routes['${options.method} ${options.path}'] ??
        (404, fakeError('NOT_FOUND'));
    return ResponseBody.fromString(
      body == null ? '' : jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, Object?> fakeError(String code) => {
  'error': {'code': code, 'message': code, 'detail': null},
};
