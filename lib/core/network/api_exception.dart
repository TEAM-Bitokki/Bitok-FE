import 'package:dio/dio.dart';

import 'error_code.dart';

// ApiClient를 거친 모든 실패는 이 예외 하나로 통일됩니다.
// 서버 에러 형식: {"error": {"code": "...", "message": "...", "detail": {...}}}
//
// 화면 예:
//   ref.watch(someProvider).when(
//     error: (e, _) => switch ((e as ApiException).code) {
//       ErrorCode.noMenuDetected => ...,
//       ErrorCode.network || ErrorCode.timeout => ...,
//       _ => ...,
//     },
//     ...
//   );
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.detail,
    this.statusCode,
  });

  final ErrorCode code;

  /// 서버 메시지(디버깅용). 사용자에게 보여줄 문구는 code 기준으로 l10n에서 고르세요.
  final String message;

  /// 서버가 주는 추가 정보. 예: VALIDATION_ERROR → {"fields": [...]}
  final Map<String, dynamic>? detail;

  /// 서버 응답을 못 받았으면 null.
  final int? statusCode;

  factory ApiException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;

    if (body is Map && body['error'] is Map) {
      final error = body['error'] as Map;
      final detail = error['detail'];
      return ApiException(
        code: ErrorCode.fromValue(error['code'] as String?),
        message: error['message'] as String? ?? '',
        detail: detail is Map ? Map<String, dynamic>.from(detail) : null,
        statusCode: statusCode,
      );
    }

    final (code, message) = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => (ErrorCode.timeout, '요청 시간이 초과되었습니다.'),
      DioExceptionType.connectionError => (ErrorCode.network, '네트워크에 연결할 수 없습니다.'),
      DioExceptionType.cancel => (ErrorCode.cancelled, '요청이 취소되었습니다.'),
      _ => (ErrorCode.unknown, e.message ?? '알 수 없는 오류가 발생했습니다.'),
    };
    return ApiException(code: code, message: message, statusCode: statusCode);
  }

  @override
  String toString() =>
      'ApiException(${code.value}, status: $statusCode, message: $message)';
}
