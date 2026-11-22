import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_text_field.dart';
import '../../../../common/widgets/saving_state_mixin.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/models/nickname_request.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_scaffold.dart';

/// 온보딩 1단계: 닉네임 입력 화면입니다.
class OnboardingNicknameScreen extends ConsumerStatefulWidget {
  const OnboardingNicknameScreen({super.key});

  @override
  ConsumerState<OnboardingNicknameScreen> createState() =>
      _OnboardingNicknameScreenState();
}

class _OnboardingNicknameScreenState
    extends ConsumerState<OnboardingNicknameScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(onboardingProvider).nickname,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    // 닉네임은 온보딩 마지막에 저장하므로, 여기서 미리 걸러 다음 단계로 넘어가지 않게 합니다.
    if (NicknameRequest.isTooLong(_controller.text)) {
      showMessageSnackBar(
        context,
        AppLocalizations.of(context).nicknameTooLong(NicknameRequest.maxLength),
      );
      return;
    }
    context.push(AppRoutes.onboardingAllergies);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isValid = ref.watch(
      onboardingProvider.select((state) => state.isNicknameValid),
    );

    return OnboardingStepScaffold(
      headerTitle: l10n.onboardingProfileHeader,
      step: 1,
      title: l10n.onboardingNicknameTitle,
      onNext: isValid ? _onNext : null,
      body: Align(
        alignment: Alignment.topCenter,
        child: BitokTextField(
          controller: _controller,
          hintText: l10n.onboardingNicknameHint,
          textInputAction: TextInputAction.done,
          onChanged: ref.read(onboardingProvider.notifier).setNickname,
          onSubmitted: (_) {
            if (isValid) _onNext();
          },
        ),
      ),
    );
  }
}

@Preview(group: 'Screens', name: 'Onboarding · Nickname', size: Size(390, 844))
Widget onboardingNicknameScreenPreview() => const ProviderScope(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: OnboardingNicknameScreen(),
  ),
);
