import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/device_token_storage.dart';
import '../../../../core/network/error_code.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/delete_account_request.dart';
import '../models/me_response.dart';
import '../models/nickname_request.dart';
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

  /// 앱 시작 시 이 기기에 저장된 계정으로 바로 들어갈 수 있는지 확인합니다.
  ///
  /// 저장된 토큰이 없거나 조회에 실패하면(미가입·네트워크 오류 등) null을 돌려주고,
  /// 이때는 지금처럼 로그인 화면에서 시작합니다. 여기서는 가입하지 않습니다.
  Future<MeResponse?> restoreSession() async {
    if (!_deviceTokenStorage.hasToken) return null;
    try {
      return await _remoteDataSource.getMe();
    } catch (_) {
      return null;
    }
  }

  /// 닉네임을 바꾸고 바뀐 계정 정보를 돌려줍니다. 앞뒤 공백은 지웁니다.
  Future<MeResponse> updateNickname(String nickname) {
    return _remoteDataSource.updateNickname(
      NicknameRequest(nickname: nickname.trim()),
    );
  }

  /// 회원 탈퇴 후 이 기기의 deviceToken을 지웁니다.
  /// 다음 signInOrSignUp은 새 토큰으로 새 계정에 가입합니다.
  ///
  /// [deleteSavedMenus]가 true면 저장한 메뉴와 분석 기록까지 지웁니다.
  /// 탈퇴에 실패하면 토큰을 그대로 두고 ApiException을 던집니다.
  Future<void> deleteAccount({required bool deleteSavedMenus}) async {
    await _remoteDataSource.deleteAccount(
      DeleteAccountRequest(agree: true, deleteSavedMenus: deleteSavedMenus),
    );
    await _deviceTokenStorage.clear();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(deviceTokenStorageProvider),
  );
});
