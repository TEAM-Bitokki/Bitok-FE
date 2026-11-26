import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_images.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/onboarding_provider.dart';

/// 온보딩 완료 화면입니다. Start를 누르면 홈으로 이동합니다.
class OnboardingCompleteScreen extends ConsumerWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: BitokColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 52,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    BitokImages.wordmarkNavy,
                    width: 69,
                    height: 40,
                    // 홈 상단 로고와 같은 설정입니다.
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Image.asset(
                BitokImages.profileReady,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.onboardingCompleteTitle,
                style: BitokTextStyles.title.copyWith(color: BitokColors.text),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.onboardingCompleteDescription,
                style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
              ),
              const Spacer(),
              BitokButton(
                label: l10n.onboardingStart,
                onPressed: () {
                  ref.read(onboardingProvider.notifier).reset();
                  context.go(AppRoutes.home);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Onboarding · Complete', size: Size(390, 844))
Widget onboardingCompleteScreenPreview() => const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: OnboardingCompleteScreen(),
  ),
);
