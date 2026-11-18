import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_state.dart';

// presentation/providers: Riverpod Notifier로 화면의 비즈니스 로직(이벤트 처리)을
// 담당합니다. presentation/screens, presentation/widgets는 이 provider만
// watch/read하고, data 계층(repository)은 이 안에서만 호출합니다.
class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginInitial();

  /// 이 기기의 계정으로 시작합니다. 처음이면 서버에 자동으로 가입합니다.
  /// 결과의 me.hasProfile로 온보딩/홈을 나눕니다.
  Future<void> start() async {
    if (state is LoginLoading) return;
    state = const LoginLoading();
    try {
      final me = await ref.read(authRepositoryProvider).signInOrSignUp();
      state = LoginSuccess(me);
    } on ApiException catch (e) {
      state = LoginFailure(e);
    }
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);
