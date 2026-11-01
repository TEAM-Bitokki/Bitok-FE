import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 오른쪽 화살표가 있는 설정 메뉴 항목입니다. 항목 전체를 누를 수 있습니다.
class BitokSettingMenu extends StatelessWidget {
  const BitokSettingMenu({super.key, required this.label, this.onTap, this.labelColor = BitokColors.text,});

  /// 메뉴 이름입니다. 예: 'Saved Menus'
  final String label;

  /// 항목을 누르면 호출됩니다.
  final VoidCallback? onTap;
  final Color labelColor;

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
                    color: labelColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
    child: BitokSettingMenu(label: 'Saved Menus', onTap: () {}),
  ),
);
