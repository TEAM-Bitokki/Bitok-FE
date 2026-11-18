// core/config: 앱 전역에서 쓰는 설정값(서버 주소, 빌드 환경 등)을 모아두는 곳입니다.
// 예: core/network의 ApiClient가 AppConfig.apiBaseUrl을 읽어 Dio의 baseUrl로 사용합니다.
//
// 값은 dart_defines.json(gitignore 대상)에서 --dart-define-from-file로 주입합니다.
// 예: {"API_BASE_URL": "http://13.125.168.145:8000"}
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// 앱 시작 시 호출합니다. assert와 달리 release 빌드에서도 검사합니다.
  /// 설정이 잘못되면 로그인까지 가서 알 수 없는 오류가 나는 대신 바로 멈춥니다.
  static void validate() {
    final uri = Uri.tryParse(apiBaseUrl);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) {
      throw StateError(
        'API_BASE_URL이 올바르지 않습니다: "$apiBaseUrl"\n'
        'dart_defines.json에 "API_BASE_URL": "http://13.125.168.145:8000" 처럼 '
        'http(s)://로 시작하는 주소를 설정하세요. '
        '(실행 설정의 Additional run args: --dart-define-from-file=dart_defines.json)',
      );
    }
  }
}
