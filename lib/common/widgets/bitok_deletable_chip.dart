import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 삭제 가능한 칩 (Figma: SelectedDietTag)
///
/// 오른쪽 X 아이콘을 누르면 [onDelete]가 호출됩니다.
class BitokDeletableChip extends StatelessWidget {
  const BitokDeletableChip({super.key, required this.label, this.onDelete});

  final String label;
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
