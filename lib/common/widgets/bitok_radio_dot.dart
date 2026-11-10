import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_icons.dart';

/// 16×16 라디오 표시입니다. 선택 여부에 따라 시안의 라디오 아이콘을 보여줍니다.
class BitokRadioDot extends StatelessWidget {
  const BitokRadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      selected ? BitokIcons.radioSelected16 : BitokIcons.radioDefault16,
      width: 16,
      height: 16,
    );
  }
}
