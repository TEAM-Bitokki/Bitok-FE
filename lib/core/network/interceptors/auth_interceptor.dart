import 'package:dio/dio.dart';

import '../device_token_storage.dart';

// 모든 요청 헤더에 deviceToken을 붙입니다.
// options.extra[skipAuthKey] == true 인 요청(가입)은 건너뜁니다. → ApiClient.noAuth
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  static const skipAuthKey = 'skipAuth';
  static const headerName = 'deviceToken';

  final DeviceTokenStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra[skipAuthKey] != true) {
      options.headers[headerName] = _storage.token;
    }
    handler.next(options);
  }
}
