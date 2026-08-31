import 'package:dio/dio.dart';

import '../models/user_model.dart';

// data/datasources: 서버 API, 로컬 DB 등 외부 데이터 소스와 직접 통신하는 계층입니다.
// repositories만 이 클래스를 호출하고, presentation(화면·provider)은 datasources를
// 직접 참조하지 않습니다.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
