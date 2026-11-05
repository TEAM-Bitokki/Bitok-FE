import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_icons.dart';
import '../../../../core/design_system/bitok_text_styles.dart';

/// 체크박스와 문구로 이루어진 세부 옵션 한 줄입니다. 예: 채식 선택 시 'I eat eggs'
class OnboardingCheckOption extends StatelessWidget {
  const OnboardingCheckOption({
    super.key,
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!checked),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: BitokColors.white,
                border: Border.all(color: BitokColors.grey1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: checked
                  ? SvgPicture.asset(BitokIcons.check13, width: 13, height: 13)
                  : null,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: BitokTextStyles.body2.copyWith(color: BitokColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
