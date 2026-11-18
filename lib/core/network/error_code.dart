// 서버 에러 응답 {"error": {"code", ...}}의 code 값입니다.
// 화면 분기는 message 문자열이 아니라 이 enum으로 하세요.
// 서버 목록: http://13.125.168.145:8000/openapi.json → components.schemas.ErrorCode
enum ErrorCode {
  // ── 서버가 내려주는 코드 ──
  validationError('VALIDATION_ERROR'),
  invalidImage('INVALID_IMAGE'),
  profileRequired('PROFILE_REQUIRED'),
  ocrLowConfidence('OCR_LOW_CONFIDENCE'),
  noMenuDetected('NO_MENU_DETECTED'),
  unauthorized('UNAUTHORIZED'),
  notFound('NOT_FOUND'),
  alreadyExists('ALREADY_EXISTS'),
  methodNotAllowed('METHOD_NOT_ALLOWED'),
  rateLimited('RATE_LIMITED'),
  llmUnavailable('LLM_UNAVAILABLE'),
  llmTimeout('LLM_TIMEOUT'),
  mapUnavailable('MAP_UNAVAILABLE'),
  notImplemented('NOT_IMPLEMENTED'),

  // ── 앱에서 붙이는 코드 (서버 응답을 못 받은 경우) ──
  network('NETWORK'),
  invalidResponse('INVALID_RESPONSE'), // 성공 응답이지만 형식이 모델과 다름
  timeout('TIMEOUT'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  const ErrorCode(this.value);

  final String value;

  /// 모르는 코드가 와도 앱이 죽지 않도록 unknown으로 처리합니다.
  static ErrorCode fromValue(String? value) => ErrorCode.values.firstWhere(
    (code) => code.value == value,
    orElse: () => ErrorCode.unknown,
  );
}
