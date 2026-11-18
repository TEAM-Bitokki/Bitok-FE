import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/device_token_storage.dart';
import '../../../../core/network/error_code.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/me_response.dart';
import '../models/sign_up_request.dart';

// data/repositories: datasources를 조합해 presentation 계층이 쓰기 편한 형태로
// 데이터를 노출합니다. 원격/로컬 등 여러 datasource를 함께 써야 할 때 이곳에서 조율합니다.
// 예: presentation/providers의 LoginNotifier가 이 repository를 호출합니다.
class AuthRepository {
  AuthRepository(this._remoteDataSource, this._deviceTokenStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final DeviceTokenStorage _deviceTokenStorage;

  /// 이 기기의 계정을 돌려줍니다. 서버에 등록되지 않은 토큰이면 먼저 가입합니다.
  ///
  /// 그 밖의 실패(네트워크 등)는 ApiException 그대로 던집니다.
  Future<MeResponse> signInOrSignUp() async {
    try {
      return await _remoteDataSource.getMe();
    } on ApiException catch (e) {
      if (e.code != ErrorCode.unauthorized) rethrow;
      return _remoteDataSource.signUp(
        SignUpRequest(deviceToken: _deviceTokenStorage.token),
      );
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(deviceTokenStorageProvider),
  );
});
