import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 라디오 버튼이 있는 단일 선택 항목입니다. 항목 전체를 누를 수 있습니다.
///
/// 여러 항목 중 하나만 선택되도록 하려면, 사용하는 쪽에서 선택된 항목을
/// 관리하고 각 항목의 [selected]에 넘깁니다.
class BitokSelectionTile extends StatelessWidget {
  const BitokSelectionTile({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  /// 항목 이름입니다. 예: 'Vegan'
  final String label;

  /// 선택 여부입니다.
  final bool selected;

  /// 항목을 누르면 호출됩니다.
  final VoidCallback? onTap;

  static const double height = 60;
  static const Duration _animationDuration = Duration(milliseconds: 150);
  static final BorderRadius _borderRadius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: _animationDuration,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: BitokColors.white,
            borderRadius: _borderRadius,
          ),
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: selected ? BitokColors.blue1 : BitokColors.grey1,
            ),
            borderRadius: _borderRadius,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: _animationDuration,
                child: SvgPicture.asset(
                  selected
                      ? BitokIcons.radioSelected16
                      : BitokIcons.radioDefault16,
                  key: ValueKey(selected),
                  width: 16,
                  height: 16,
                ),
              ),
              const SizedBox(width: 21),
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
            ],
          ),
        ),
      ),
    );
  }
}

@Preview(group: 'Common', name: 'Selection Tile', size: Size(390, 200))
Widget selectionTilePreview() => const _SelectionTilePreview();

class _SelectionTilePreview extends StatefulWidget {
  const _SelectionTilePreview();

  @override
  State<_SelectionTilePreview> createState() => _SelectionTilePreviewState();
}

class _SelectionTilePreviewState extends State<_SelectionTilePreview> {
  static const List<String> _options = ['No particular diet', 'Vegan'];
  String _selected = 'Vegan';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BitokColors.grey3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          spacing: 16,
          children: [
            for (final option in _options)
              BitokSelectionTile(
                label: option,
                selected: option == _selected,
                onTap: () => setState(() => _selected = option),
              ),
          ],
        ),
      ),
    );
  }
}
