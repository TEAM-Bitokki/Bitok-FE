import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 단일 선택 항목 (Figma: Selection / Chips, 543:2847의 DietCheck_off / DietCheck_on)
///
/// 항목 전체가 터치 영역입니다. 여러 항목 중 하나만 선택되도록 하는
/// 그룹 상태는 사용하는 쪽에서 관리합니다.
class BitokSelectionTile extends StatelessWidget {
  const BitokSelectionTile({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
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
          // 테두리가 내부 콘텐츠 위치를 밀지 않도록 foregroundDecoration으로 그립니다.
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: selected ? BitokColors.blue1 : BitokColors.grey1,
            ),
            borderRadius: _borderRadius,
          ),
          child: Row(
            children: [
              _RadioIndicator(selected: selected, duration: _animationDuration),
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

/// 16×16 라디오 표시. 터치는 [BitokSelectionTile]이 받으므로 표시 전용입니다.
class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected, required this.duration});

  final bool selected;
  final Duration duration;

  // Figma 원본 값입니다. 디자인 시스템(BitokColors)에 대응 토큰이 없습니다.
  static const Color _offColor = Color(0xFFC6C6C6);
  static const Color _onColor = Color(0xFF7E7E7E);

  @override
  Widget build(BuildContext context) {
    final color = selected ? _onColor : _offColor;

    return AnimatedContainer(
      duration: duration,
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color),
      ),
      child: AnimatedScale(
        duration: duration,
        scale: selected ? 1 : 0,
        child: const DecoratedBox(
          decoration: BoxDecoration(color: _onColor, shape: BoxShape.circle),
          child: SizedBox.square(dimension: 10),
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
