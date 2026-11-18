import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/login_provider.dart';
import '../providers/login_state.dart';
import '../widgets/login_header.dart';

// presentation/screens: 화면은 UI 조립 역할만 담당하도록 얇게 유지합니다.
// 실제 로직은 presentation/providers, 개별 UI 조각은 presentation/widgets에 위임합니다.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(loginProvider) is LoginLoading;

    ref.listen(loginProvider, (_, next) {
      switch (next) {
        case LoginSuccess(:final me):
          context.go(me.hasProfile ? AppRoutes.home : AppRoutes.onboardingNickname);
        case LoginFailure():
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.errorTryAgain)));
        case LoginInitial() || LoginLoading():
          break;
      }
    });

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
                onPressed: isLoading
                    ? null
                    : () => ref.read(loginProvider.notifier).start(),
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
