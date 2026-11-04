import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_icons.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import 'my_page_card.dart';

class MyPageDietaryCard extends StatelessWidget {
  const MyPageDietaryCard({super.key, required this.summary, this.onTap});


  final String summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MyPageCard(
      color: BitokColors.blue2,
      radius: 20,
      height: 120,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 30, 54, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(BitokIcons.meal30, width: 30, height: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Dietary Profile',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // 디자인 시스템 subTitle 은 24px 인데 시안은 20px 라서 크기만 맞춥니다.
                    style: BitokTextStyles.subTitle.copyWith(
                      fontSize: 20,
                      color: BitokColors.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BitokTextStyles.body2.copyWith(color: BitokColors.grey0),
            ),
          ],
        ),
      ),
    );
  }
}
