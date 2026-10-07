// core/config: 앱 전역에서 쓰는 설정값(서버 주소, 빌드 환경 등)을 모아두는 곳입니다.
// 예: core/network의 ApiClient가 AppConfig.apiBaseUrl을 읽어 Dio의 baseUrl로 사용합니다.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'https://api.bitok.app';
}
