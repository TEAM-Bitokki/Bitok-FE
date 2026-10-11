import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 프로필 정보 카드 (Figma: Profile / Settings, 543:2958의 Menu_Profile_show / Menu_Profile_edit)
///
/// [onEdit]이 있으면 오른쪽에 편집 아이콘이 표시됩니다(edit 상태).
class BitokProfileCard extends StatelessWidget {
  const BitokProfileCard({
    super.key,
    required this.title,
    required this.description,
    this.iconAsset = BitokIcons.meal30,
    this.onEdit,
  });

  /// 예: 'Food Allergies'
  final String title;

  /// 예: 'Shrimp · Anchovy · Walnut'
  final String description;

  /// 제목 왼쪽의 30×30 아이콘
  final String iconAsset;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final onEdit = this.onEdit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
      decoration: BoxDecoration(
        color: BitokColors.grey3,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(iconAsset, width: 30, height: 30),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BitokTextStyles.subTitle.copyWith(
                          color: BitokColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BitokTextStyles.body2.copyWith(
                    color: BitokColors.grey0,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 12),
            Semantics(
              button: true,
              label: 'Edit $title',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEdit,
                child: SvgPicture.asset(
                  BitokIcons.edit24,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@Preview(group: 'Common', name: 'Profile Card', size: Size(390, 600))
Widget profileCardPreview() => ColoredBox(
  color: BitokColors.white,
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      spacing: 22,
      children: [
        const BitokProfileCard(
          title: 'Food Allergies',
          description: 'Shrimp · Anchovy · Walnut',
        ),
        BitokProfileCard(
          title: 'Food Allergies',
          description: 'Shrimp · Anchovy · Walnut',
          onEdit: () {},
        ),
        const BitokProfileCard(
          title: 'Dietary Preference',
          description: 'No particular diet',
        ),
        BitokProfileCard(
          title: 'Dietary Preference',
          description: 'No particular diet',
          onEdit: () {},
        ),
      ],
    ),
  ),
);
