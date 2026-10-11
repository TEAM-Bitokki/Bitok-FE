import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 오른쪽에 X 삭제 버튼이 있는 칩입니다. 너비는 문구 길이에 맞춰집니다.
class BitokDeletableChip extends StatelessWidget {
  const BitokDeletableChip({super.key, required this.label, this.onDelete});

  /// 칩에 표시할 문구입니다. 예: 'Prawn'
  final String label;

  /// X 버튼을 누르면 호출됩니다.
  final VoidCallback? onDelete;

  static const double height = 32;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 14, right: 10),
      decoration: BoxDecoration(
        color: BitokColors.blue2,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BitokTextStyles.body3.copyWith(color: BitokColors.text),
            ),
          ),
          Semantics(
            button: true,
            label: 'Delete $label',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDelete,
              child: SvgPicture.asset(
                BitokIcons.exitSmall24,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'Common', name: 'Deletable Chip', size: Size(300, 80))
Widget deletableChipPreview() => ColoredBox(
  color: BitokColors.white,
  child: Center(
    child: BitokDeletableChip(label: 'Prawn', onDelete: () {}),
  ),
);
