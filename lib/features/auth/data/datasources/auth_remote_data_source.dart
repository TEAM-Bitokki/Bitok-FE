import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/delete_account_request.dart';
import '../models/me_response.dart';
import '../models/nickname_request.dart';
import '../models/sign_up_request.dart';

// data/datasources: 서버 API, 로컬 DB 등 외부 데이터 소스와 직접 통신하는 계층입니다.
// repositories만 이 클래스를 호출하고, presentation(화면·provider)은 datasources를
// 직접 참조하지 않습니다.
//
// 메서드 하나 = API 하나. ApiClient가 헤더·에러 변환을 처리하므로
// 여기서는 경로와 모델 변환(ApiClient.decode)만 씁니다.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiClient _api;

  /// 이 요청만 deviceToken 헤더 없이 보냅니다. 토큰은 body에 담습니다.
  Future<MeResponse> signUp(SignUpRequest request) async => ApiClient.decode(
    await _api.post(
      '/api/auth/sign-up',
      data: request.toJson(),
      options: ApiClient.noAuth,
    ),
    MeResponse.fromJson,
  );

  /// 등록되지 않은 토큰이면 ApiException(ErrorCode.unauthorized)을 던집니다.
  Future<MeResponse> getMe() async =>
      ApiClient.decode(await _api.get('/api/auth/me'), MeResponse.fromJson);

  /// 바뀐 계정 정보를 돌려줍니다.
  Future<MeResponse> updateNickname(NicknameRequest request) async =>
      ApiClient.decode(
        await _api.patch('/api/users/me', data: request.toJson()),
        MeResponse.fromJson,
      );

  /// 성공하면 204(body 없음)입니다. 이후 이 deviceToken은 401이 됩니다.
  Future<void> deleteAccount(DeleteAccountRequest request) async {
    await _api.delete('/api/users/me', data: request.toJson());
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});
