import '../../data/models/user_model.dart';

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
  const LoginSuccess(this.user);

  final UserModel user;
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;
}
