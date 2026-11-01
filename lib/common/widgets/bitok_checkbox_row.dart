import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// Figma: 체크박스(20x20) + 라벨 + (선택) 보조 설명
class BitokCheckboxRow extends StatelessWidget {
  const BitokCheckboxRow({
    super.key,
    required this.label,
    required this.checked,
    this.description,
    this.onChanged,
  });

  final String label;
  final String? description;
  final bool checked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onChanged == null ? null : () => onChanged!(!checked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            checked ? BitokIcons.checkboxChecked20 : BitokIcons.checkboxDefault20,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: BitokTextStyles.body2.copyWith(color: BitokColors.text),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: BitokTextStyles.body3.copyWith(
                      color: BitokColors.grey0,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(group: 'Components', name: 'Checkbox Row', size: Size(390, 200))
Widget checkboxRowPreview() => MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    backgroundColor: BitokColors.white,
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        BitokCheckboxRow(
          label: 'Required · I agree to delete my account.',
          description: 'All account information will be permanently deleted.',
          checked: true,
        ),
        SizedBox(height: 15),
        BitokCheckboxRow(label: 'I eat eggs', checked: false),
      ],
    ),
  ),
);
