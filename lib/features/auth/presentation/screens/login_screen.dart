import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/login_provider.dart';
import '../widgets/login_header.dart';

// presentation/screens: 화면은 UI 조립 역할만 담당하도록 얇게 유지합니다.
// 실제 로직은 presentation/providers, 개별 UI 조각은 presentation/widgets에 위임합니다.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _onGetStarted(BuildContext context, WidgetRef ref) async {
    // TODO: 로그인 플로우가 준비되면 로그인 성공 후에 아래 분기를 실행합니다.
    final isFirstLogin = await ref.read(loginProvider.notifier).isFirstLogin();
    if (!context.mounted) return;
    context.go(isFirstLogin ? AppRoutes.onboardingNickname : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: BitokColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: Column(
            children: [
              // 디자인 기준 상단(로고 위) 190px, 하단(문구~버튼) 284px 비율로 배치합니다.
              const Spacer(flex: 190),
              const LoginHeader(),
              const Spacer(flex: 284),
              BitokButton(
                label: l10n.getStarted,
                variant: BitokButtonVariant.login,
                onPressed: () => _onGetStarted(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Login', size: Size(390, 844))
Widget loginScreenPreview() => const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LoginScreen(),
  ),
);
