import 'package:dio/dio.dart';

import '../config/app_config.dart';

// core/network: 서버와 통신하는 Dio 클라이언트를 초기화하고 baseUrl, 헤더,
// 인터셉터 같은 공통 설정을 관리합니다.
// 예: features/auth/data/datasources의 AuthRemoteDataSource가 이 클라이언트를
// 생성자로 주입받아 API를 호출합니다.
class ApiClient {
  ApiClient() : dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));

  final Dio dio;
}
