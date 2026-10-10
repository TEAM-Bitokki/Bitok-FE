import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';
import 'radio_dot.dart';


class BitokOcrMenuItem extends StatelessWidget {
  const BitokOcrMenuItem._({
    super.key,
    required this.koreanName,
    required this.englishName,
    this.selectable = false,
    this.selected = false,
    this.onTap,
    this.onEdit,
  });

  factory BitokOcrMenuItem.selectable({
    Key? key,
    required String koreanName,
    required String englishName,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return BitokOcrMenuItem._(
      key: key,
      koreanName: koreanName,
      englishName: englishName,
      selectable: true,
      selected: selected,
      onTap: onTap,
    );
  }

  factory BitokOcrMenuItem.editable({
    Key? key,
    required String koreanName,
    required String englishName,
    VoidCallback? onEdit,
  }) {
    return BitokOcrMenuItem._(
      key: key,
      koreanName: koreanName,
      englishName: englishName,
      onEdit: onEdit,
    );
  }

  final String koreanName;
  final String englishName;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final showBorder = selectable && selected;

    return Material(
      color: BitokColors.grey3,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: selectable ? onTap : null,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showBorder ? BitokColors.blue1 : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(17, 14, 17, 14),
          child: Row(
            children: [
              if (selectable) ...[
                BitokRadioDot(selected: selected),
                const SizedBox(width: 21),
              ],
              Expanded(child: _names()),
              if (!selectable)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onEdit,
                  child: SvgPicture.asset(
                    BitokIcons.edit24,
                    width: 24,
                    height: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _names() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          koreanName,
          style: BitokTextStyles.body1KOR.copyWith(color: BitokColors.text),
        ),
        const SizedBox(height: 6),
        Text(
          englishName,
          style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
        ),
      ],
    );
  }
}


@Preview(group: 'Components', name: 'OCR Menu', size: Size(390, 380))
Widget ocrMenuPreview() => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.white,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        BitokOcrMenuItem.selectable(
          koreanName: '김치찌개',
          englishName: 'Kimchi Jjigae',
          selected: false,
        ),
        const SizedBox(height: 12),
        BitokOcrMenuItem.selectable(
          koreanName: '김치찌개',
          englishName: 'Kimchi Jjigae',
          selected: true,
        ),
        const SizedBox(height: 12),
        BitokOcrMenuItem.editable(
          koreanName: '김치찌개',
          englishName: 'Kimchi Jjigae',
        ),
      ],
    ),
  ),
);