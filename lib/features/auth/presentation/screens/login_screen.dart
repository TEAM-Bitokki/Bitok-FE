import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/login_provider.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';
import '../widgets/social_login_buttons.dart';

// presentation/screens: 화면은 UI 조립 역할만 담당하도록 얇게 유지합니다.
// 실제 로직은 presentation/providers, 개별 UI 조각은 presentation/widgets에 위임합니다.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loginProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LoginHeader(),
              const SizedBox(height: 32),
              LoginForm(
                onSubmit: (email, password) =>
                    notifier.login(email: email, password: password),
              ),
              const SizedBox(height: 16),
              SocialLoginButtons(
                onGooglePressed: () {},
                onApplePressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
