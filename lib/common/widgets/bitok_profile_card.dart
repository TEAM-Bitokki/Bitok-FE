import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_system/bitok_colors.dart';
import '../../core/design_system/bitok_icons.dart';
import '../../core/design_system/bitok_text_styles.dart';

/// 알레르기, 식단 같은 프로필 정보 카드입니다.
///
/// [onEdit]을 넘기면 오른쪽에 편집 아이콘이 표시됩니다.
class BitokProfileCard extends StatelessWidget {
  const BitokProfileCard({
    super.key,
    required this.title,
    required this.description,
    this.iconAsset = BitokIcons.meal30,
    this.onEdit,
  });

  /// 카드 제목입니다. 예: 'Food Allergies'
  final String title;

  /// 제목 아래에 표시할 내용입니다. 예: 'Shrimp · Anchovy · Walnut'
  final String description;

  /// 제목 왼쪽에 표시할 30×30 SVG 아이콘 경로입니다. 기본값은 [BitokIcons.meal30]입니다.
  final String iconAsset;

  /// 편집 아이콘을 누르면 호출됩니다. 없으면 편집 아이콘이 표시되지 않습니다.
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
