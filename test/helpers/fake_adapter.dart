import 'dart:convert';

import 'package:dio/dio.dart';

/// 실제 서버 대신 경로별로 정해둔 응답을 돌려주는 어댑터.
/// 키는 'METHOD /path' 형식이고, 값은 (상태 코드, body)입니다. body가 null이면 빈 응답입니다.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.routes);

  final Map<String, (int, Object?)> routes;
  final requests = <RequestOptions>[];

  /// 키에 해당하는 요청은 이 Future가 끝날 때까지 응답을 미룹니다. 요청이 겹치는 경우를 테스트할 때 씁니다.
  final gates = <String, Future<void>>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? _,
    Future<void>? _,
  ) async {
    requests.add(options);
    final key = '${options.method} ${options.path}';
    await gates[key];
    final (status, body) = routes[key] ?? (404, fakeError('NOT_FOUND'));
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
