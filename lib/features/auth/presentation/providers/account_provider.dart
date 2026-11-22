import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/me_response.dart';
import '../../data/repositories/auth_repository.dart';

/// 로그인한 사용자의 계정 정보입니다. 마이페이지와 프로필 수정 화면이 보여줍니다.
class Account {
  const Account({required this.userId, required this.nickname});

  /// 서버 응답으로 만듭니다. 닉네임을 정하기 전(온보딩 전)이면 빈 문자열입니다.
  factory Account.fromMe(MeResponse me) =>
      Account(userId: me.userId, nickname: me.nickname ?? '');

  final int userId;
  final String nickname;
}

/// 로그인 전에는 null입니다. 로그인에 성공하면 [setFromMe]로 채웁니다.
///
/// 앱은 항상 로그인 화면(GET /api/auth/me)을 거쳐 시작하므로,
/// 여기서 다시 조회하지 않고 로그인 결과를 그대로 씁니다.
class AccountNotifier extends Notifier<Account?> {
  @override
  Account? build() => null;

  void setFromMe(MeResponse me) => state = Account.fromMe(me);

  /// 닉네임을 서버에 저장하고, 응답으로 계정 정보를 갱신합니다.
  ///
  /// 응답을 기다리는 동안 탈퇴했거나 계정이 바뀌었으면 응답을 반영하지 않습니다.
  /// (탈퇴한 계정이 다시 로그인 상태로 돌아오지 않도록)
  /// 실패하면 상태를 바꾸지 않고 ApiException을 던집니다.
  Future<void> saveNickname(String nickname) async {
    final me = await ref.read(authRepositoryProvider).updateNickname(nickname);
    if (state?.userId != me.userId) return;
    state = Account.fromMe(me);
  }

  /// 회원 탈퇴 후 로그아웃 상태(null)가 됩니다. 이 기기의 deviceToken도 지워지므로,
  /// 다음 로그인은 새 계정으로 가입합니다.
  ///
  /// 실패하면 상태와 토큰을 그대로 두고 ApiException을 던집니다.
  /// 계정에 딸린 다른 화면 상태는 호출한 쪽(라우터)이 비웁니다.
  Future<void> deleteAccount({required bool deleteSavedMenus}) async {
    await ref
        .read(authRepositoryProvider)
        .deleteAccount(deleteSavedMenus: deleteSavedMenus);
    state = null;
  }
}

final accountProvider = NotifierProvider<AccountNotifier, Account?>(
  AccountNotifier.new,
);
