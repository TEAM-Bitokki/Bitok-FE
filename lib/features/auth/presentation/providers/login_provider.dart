import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_state.dart';

// presentation/providers: Riverpod Notifier로 화면의 비즈니스 로직(이벤트 처리)을
// 담당합니다. presentation/screens, presentation/widgets는 이 provider만
// watch/read하고, data 계층(repository)은 이 안에서만 호출합니다.
class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginInitial();

  Future<void> login({required String email, required String password}) async {
    state = const LoginLoading();
    // TODO: features/auth/data/repositories/auth_repository.dart의 AuthRepository를
    // 호출해 결과를 LoginSuccess/LoginFailure로 반영합니다.
  }

  /// 처음 로그인한 사용자인지 확인합니다. true면 온보딩을 보여줍니다.
  Future<bool> isFirstLogin() async {
    // TODO: 로그인 API 연동 시 서버 응답(예: 신규 가입 여부, 프로필 등록 여부)으로 판단합니다.
    // 연동 전까지는 온보딩 플로우를 확인할 수 있도록 항상 true를 반환합니다.
    return true;
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);
