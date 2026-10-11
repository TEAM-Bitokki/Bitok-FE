import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 설정 메뉴 항목 (Figma: Profile / Settings, 543:2958의 Setting_menu)
///
/// 항목 전체가 터치 영역입니다.
class BitokSettingMenu extends StatelessWidget {
  const BitokSettingMenu({super.key, required this.label, this.onTap});

  /// 예: 'Saved Menues'
  final String label;
  final VoidCallback? onTap;

  static const double height = 60;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: BitokColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BitokTextStyles.body1KOR.copyWith(
                    color: BitokColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 에셋 이름과 달리 오른쪽을 향하는 회색 chevron입니다.
              SvgPicture.asset(BitokIcons.leftArrow24, width: 24, height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Common', name: 'Setting Menu', size: Size(390, 120))
Widget settingMenuPreview() => ColoredBox(
  color: BitokColors.grey3,
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: BitokSettingMenu(label: 'Saved Menues', onTap: () {}),
  ),
);
