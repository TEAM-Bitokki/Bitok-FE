import 'package:flutter/material.dart';

// presentation/widgets: 화면(screens)을 구성하는 개별 UI 섹션을 분리해서 화면 파일이
// 비대해지지 않도록 합니다. login_screen.dart는 이 위젯들을 조립하기만 합니다.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Bitok',
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }
}
