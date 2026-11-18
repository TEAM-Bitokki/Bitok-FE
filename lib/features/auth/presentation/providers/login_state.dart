import '../../../../core/network/api_exception.dart';
import '../../data/models/me_response.dart';

// presentation/providers: 화면의 상태(State)를 정의합니다.
// login_provider.dart가 이 상태를 만들어내고, login_screen.dart가 watch해서
// 로딩/성공/실패에 따라 다른 UI를 그립니다.
sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.me);

  final MeResponse me;
}

class LoginFailure extends LoginState {
  const LoginFailure(this.error);

  /// 화면 분기는 error.code(ErrorCode)로 합니다.
  final ApiException error;
}
