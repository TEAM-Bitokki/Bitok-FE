import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인한 사용자의 계정 정보입니다. 마이페이지와 프로필 수정 화면이 보여줍니다.
class Account {
  const Account({required this.nickname});

  final String nickname;

  Account copyWith({String? nickname}) {
    return Account(nickname: nickname ?? this.nickname);
  }
}

class AccountNotifier extends Notifier<Account> {
  // TODO: 로그인/프로필 조회 API가 준비되면 서버 값으로 초기화합니다.
  @override
  Account build() => const Account(nickname: 'Biiiiii');

  // TODO: 닉네임 저장 API를 연결합니다.
  void saveNickname(String nickname) {
    state = state.copyWith(nickname: nickname.trim());
  }
}

final accountProvider = NotifierProvider<AccountNotifier, Account>(
  AccountNotifier.new,
);
