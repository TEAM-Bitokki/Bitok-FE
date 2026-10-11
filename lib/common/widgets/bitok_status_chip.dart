import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 메뉴의 섭취 가능 여부 판정 결과입니다.
enum BitokMenuStatus {
  /// 먹어도 안전합니다. 초록색 'Safe' 칩으로 표시됩니다.
  safe('Safe', BitokColors.green2),

  /// 피해야 합니다. 빨간색 'Avoid' 칩으로 표시됩니다.
  avoid('Avoid', BitokColors.red2),

  /// 확인이 필요합니다. 노란색 'Not Sure' 칩으로 표시됩니다.
  notSure('Not Sure', BitokColors.yellow2);

  const BitokMenuStatus(this.label, this.backgroundColor);

  final String label;

  final Color backgroundColor;
}

/// 메뉴 판정 결과를 표시하는 알약 모양 칩입니다.
class BitokStatusChip extends StatelessWidget {
  const BitokStatusChip({super.key, required this.status});

  /// 표시할 판정 결과입니다.
  final BitokMenuStatus status;

  static const double width = 80;

  static const double height = 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Text(
        status.label,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: BitokTextStyles.body3.copyWith(color: BitokColors.text),
      ),
    );
  }
}

@Preview(group: 'Common', name: 'Status Chip', size: Size(320, 80))
Widget statusChipPreview() => ColoredBox(
  color: BitokColors.white,
  child: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final status in BitokMenuStatus.values) ...[
          BitokStatusChip(status: status),
          const SizedBox(width: 12),
        ],
      ],
    ),
  ),
);
