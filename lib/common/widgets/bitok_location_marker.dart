import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 지도 위치 마커 칩 (Figma: Location Marker / Location Marker Selected)
///
/// 마커 모양은 28×36이며, 그림자는 레이아웃 크기 밖(사방 4)으로 그려집니다.
class BitokLocationMarker extends StatelessWidget {
  const BitokLocationMarker({
    super.key,
    required this.count,
    this.selected = false,
    this.onTap,
  });

  /// 마커 안에 표시할 숫자
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  static const double width = 28;
  static const double height = 36;

  // SVG 에셋(36×44)에 포함된 그림자 여백
  static const double _shadowInset = 4;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$count',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -_shadowInset,
                top: -_shadowInset,
                child: SvgPicture.asset(
                  selected
                      ? BitokIcons.locationSelected
                      : BitokIcons.locationDefault,
                  width: width + _shadowInset * 2,
                  height: height + _shadowInset * 2,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: BitokTextStyles.body1.copyWith(
                    color: selected ? BitokColors.white : BitokColors.primary,
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

@Preview(group: 'Common', name: 'Location Marker', size: Size(200, 100))
Widget locationMarkerPreview() => const ColoredBox(
  color: BitokColors.grey2,
  child: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        BitokLocationMarker(count: 4),
        BitokLocationMarker(count: 9, selected: true),
      ],
    ),
  ),
);
