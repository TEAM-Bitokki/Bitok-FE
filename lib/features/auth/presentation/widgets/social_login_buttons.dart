import 'package:flutter/material.dart';

// presentation/widgets: 소셜 로그인처럼 유사한 버튼 여러 개를 한 세트로 묶어
// login_screen.dart에서 한 번에 배치할 수 있게 합니다.
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton(onPressed: onGooglePressed, child: const Text('Continue with Google')),
        OutlinedButton(onPressed: onApplePressed, child: const Text('Continue with Apple')),
      ],
    );
  }
}
