// core/config: 앱 전역에서 쓰는 설정값(서버 주소, 빌드 환경 등)을 모아두는 곳입니다.
// 예: core/network의 ApiClient가 AppConfig.apiBaseUrl을 읽어 Dio의 baseUrl로 사용합니다.
//
// 값은 dart_defines.json(gitignore 대상)에서 --dart-define-from-file로 주입합니다.
// 예: {"API_BASE_URL": "http://13.125.168.145:8000"}
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
}
