import 'package:flutter/material.dart';

import '../../../../core/design_system/bitok_colors.dart';

/// 온보딩 상단의 단계 진행 막대입니다.
///
/// [currentStep]까지의 막대는 primary, 나머지는 grey2로 칠합니다. (1부터 시작)
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $currentStep of $totalSteps',
      excludeSemantics: true,
      child: Row(
        spacing: 6,
        children: [
          for (var step = 1; step <= totalSteps; step++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 5,
                decoration: BoxDecoration(
                  color: step <= currentStep
                      ? BitokColors.primary
                      : BitokColors.grey2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
