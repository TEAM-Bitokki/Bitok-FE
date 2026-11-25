import 'package:flutter/material.dart';

import '../../../../core/design_system/bitok_colors.dart';
import '../../../../core/design_system/bitok_text_styles.dart';
import 'my_page_card.dart';

class MyPageProfileCard extends StatelessWidget {
  const MyPageProfileCard({super.key, required this.nickname, this.onTap});

  final String nickname;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MyPageCard(
      color: BitokColors.white,
      radius: 12,
      height: 78,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 54),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BitokTextStyles.body1.copyWith(color: BitokColors.text),
          ),
        ),
      ),
    );
  }
}
