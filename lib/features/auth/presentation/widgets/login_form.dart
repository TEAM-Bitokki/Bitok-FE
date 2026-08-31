import 'package:flutter/material.dart';

// presentation/widgets: 입력 필드처럼 화면의 특정 섹션 하나를 담당하는 위젯입니다.
// 상태는 직접 들고 있지 않고 콜백(onSubmit)으로 부모(providers)에 이벤트만 전달합니다.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onSubmit});

  final void Function(String email, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        ElevatedButton(
          onPressed: () => widget.onSubmit(_emailController.text, _passwordController.text),
          child: const Text('Login'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
