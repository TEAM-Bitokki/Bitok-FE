import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'api_exception.dart';
import 'device_token_storage.dart';
import 'error_code.dart';
import 'interceptors/auth_interceptor.dart';

// core/network: 서버와 통신하는 Dio 클라이언트를 초기화하고 baseUrl, 헤더,
// 인터셉터 같은 공통 설정을 관리합니다.
//
// 사용법 (features/*/data/datasources):
//   class MeRemoteDataSource {
//     MeRemoteDataSource(this._api);
//     final ApiClient _api;
//
//     Future<MeResponse> getMe() async =>
//         ApiClient.decode(await _api.get('/api/auth/me'), MeResponse.fromJson);
//   }
//
//   final meRemoteDataSourceProvider = Provider(
//     (ref) => MeRemoteDataSource(ref.watch(apiClientProvider)),
//   );
//
// - 모든 메서드는 응답 body(response.data)를 그대로 돌려줍니다. 204면 null입니다.
// - body를 모델로 바꿀 때는 ApiClient.decode로 감싸세요. 형식이 다르면
//   TypeError 대신 ApiException(ErrorCode.invalidResponse)이 됩니다.
// - 실패하면 DioException이 아니라 항상 ApiException을 던집니다.
//   화면에서는 AsyncValue.error의 ApiException.code로 분기하세요.
// - deviceToken 헤더는 자동으로 붙습니다. 가입처럼 빼야 하는 요청만
//   options: ApiClient.noAuth 를 넘기세요.
// - 스캔/분석처럼 오래 걸리는 요청은 options: ApiClient.longRunning 을 넘기세요.
class ApiClient {
  ApiClient({required DeviceTokenStorage deviceTokenStorage, Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = AppConfig.apiBaseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..sendTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30)
      ..contentType = Headers.jsonContentType;

    _dio.interceptors.add(AuthInterceptor(deviceTokenStorage));
    if (kDebugMode) {
      _dio.interceptors.add(
        // 요청 헤더(deviceToken)는 로그에 남기지 않습니다.
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          logPrint: (log) => debugPrint(log.toString()),
        ),
      );
    }
  }

  final Dio _dio;

  /// deviceToken 헤더를 붙이지 않는 요청 (POST /api/auth/sign-up 전용).
  static final Options noAuth = Options(extra: {AuthInterceptor.skipAuthKey: true});

  /// 스캔·분석처럼 10~25초 이상 걸리는 요청용. 서버 LLM 타임아웃(504)보다 길게 둡니다.
  static final Options longRunning = Options(
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 90),
  );

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) => _send(() => _dio.get(path, queryParameters: query, options: options));

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) => _send(
    () => _dio.post(path, data: data, queryParameters: query, options: options),
  );

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) => _send(
    () => _dio.put(path, data: data, queryParameters: query, options: options),
  );

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) => _send(
    () => _dio.patch(path, data: data, queryParameters: query, options: options),
  );

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
  }) => _send(
    () => _dio.delete(path, data: data, queryParameters: query, options: options),
  );

  /// 성공 응답 body를 모델로 바꿉니다.
  /// body가 Map이 아니거나 필드 형식이 다르면 ApiException(invalidResponse)을 던집니다.
  ///
  /// ```dart
  /// ApiClient.decode(await _api.get('/api/auth/me'), MeResponse.fromJson);
  /// ApiClient.decode(
  ///   await _api.get('/api/restaurants/search', query: {'q': q}),
  ///   (json) => ListResponse.fromJson(json, RestaurantBrief.fromJson),
  /// );
  /// ```
  static T decode<T>(
    Object? data,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    try {
      return fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException(
        code: ErrorCode.invalidResponse,
        message: '응답 형식이 올바르지 않습니다: $e',
      );
    }
  }

  // Dio 인터셉터에서 에러를 바꿔도 호출부에는 DioException으로 감싸져 나오기 때문에,
  // ApiException 변환은 여기 한 곳에서 처리합니다.
  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(deviceTokenStorage: ref.watch(deviceTokenStorageProvider));
});
