import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/bitok_button.dart';
import '../../../../common/widgets/bitok_header.dart';
import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'onboarding_progress_bar.dart';

/// 온보딩 단계 화면(닉네임·알레르기·식단·프로필 확인)의 공통 레이아웃입니다.
///
/// 헤더 → 진행 막대 → STEP 라벨 → 제목 → [body] → [bottomAccessory] → 하단 버튼
/// 순서로 배치합니다. [onNext]가 null이면 하단 버튼이 비활성화됩니다.
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.headerTitle,
    this.step,
    required this.title,
    required this.body,
    required this.onNext,
    this.buttonLabel,
    this.onSkip,
    this.bottomAccessory,
  });

  /// 온보딩 전체 단계 수입니다.
  static const int totalSteps = 3;

  /// 화면 좌우 여백입니다. 가로로 끝까지 그려야 하는 위젯이 참고합니다.
  static const double horizontalPadding = 24;

  final String headerTitle;

  /// 현재 단계입니다. 1부터 시작합니다.
  /// null이면 진행 막대와 STEP 라벨을 숨깁니다. (마이페이지에서 프로필을 수정할 때)
  final int? step;

  final String title;

  /// 제목 아래 남은 영역을 채우는 본문입니다. 좌우 여백이 이미 적용되어 있습니다.
  final Widget body;

  final VoidCallback? onNext;

  /// 하단 버튼 문구입니다. 없으면 'Next'를 씁니다.
  final String? buttonLabel;

  /// 넘기면 헤더 오른쪽에 Skip 버튼이 표시됩니다.
  final VoidCallback? onSkip;

  /// 하단 버튼 바로 위에 붙는 영역입니다. 좌우 여백 없이 화면 끝까지 그려집니다.
  final Widget? bottomAccessory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSkip = this.onSkip;

    // 첫 단계는 go로 진입해 돌아갈 스택이 없어서, 시스템 뒤로 가기가 앱을 종료해 버립니다.
    // 헤더 뒤로 가기와 똑같이 로그인 화면으로 돌아가게 합니다. (스택이 있으면 그대로 pop)
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack(context);
      },
      child: _buildScaffold(context, l10n, onSkip),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppLocalizations l10n,
    VoidCallback? onSkip,
  ) {
    return Scaffold(
      backgroundColor: BitokColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BitokHeader.sub(
              title: headerTitle,
              onBack: () => _onBack(context),
              trailing: onSkip == null
                  ? null
                  : _SkipButton(label: l10n.onboardingSkip, onTap: onSkip),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (step case final step?) ...[
                      const SizedBox(height: 10),
                      OnboardingProgressBar(
                        currentStep: step,
                        totalSteps: totalSteps,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.onboardingStepLabel(step, totalSteps),
                        style: BitokTextStyles.body3.copyWith(
                          color: BitokColors.grey0,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: BitokTextStyles.title.copyWith(
                        color: BitokColors.text,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(child: body),
                  ],
                ),
              ),
            ),
            ?bottomAccessory,
            Padding(
              padding: const EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                10,
              ),
              child: BitokButton(
                label: buttonLabel ?? l10n.onboardingNext,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // 첫 단계는 로그인 화면에서 go로 진입하므로 돌아갈 스택이 없습니다.
      context.go(AppRoutes.login);
    }
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            label,
            style: BitokTextStyles.buttonText2.copyWith(
              color: BitokColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
