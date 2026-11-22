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
  /// 실패하면 상태를 바꾸지 않고 ApiException을 던집니다.
  Future<void> saveNickname(String nickname) async {
    final me = await ref.read(authRepositoryProvider).updateNickname(nickname);
    state = Account.fromMe(me);
  }
}

final accountProvider = NotifierProvider<AccountNotifier, Account?>(
  AccountNotifier.new,
);
